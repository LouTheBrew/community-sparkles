## Chef and Sparkleformation for Ruby awesomeness... heres how to use this.
## the component takes a component name of _name and a configuration Hash of _config
## The required contents of _config are as follows
##
## A string indicating the databag calling user
## _config[:databag_user]
##
## An amazon iam user id with sufficient permissions to access the s3 bucket containing chef-client files such as pems and certs
## _config[:chef_bucket_iam_user_id]
##
## A key to go with the user_id
## _config[:chef_bucket_iam_user_key]
##
## A databag key so the chef client can decrypt databags held by the chef server
## _config[:chef_databag_key]
##
## A string containing the configuration for a knife.rb file likely to be placed in /etc/chef/knife.rb
## _config[:knife_config]
##
## A string instead of Array containing the chef bucket name
## _config[:chef_bucket_name]
##
## A path within the _config[:chef_bucket_name] to find the validator.pem
## _config[:validation_client_s3_rel]
##
## A name for the validator, not the validator.pem but the name of the client validator for chef
##_config[:chef_validator_name]
##
## A role string in the format of example "role[my_chef_role]"
## _config[:chef_role]
##
## A string indicating the chef environment the node will belong to
## _config[:chef_environment]
##
## A string indicating the user knife should be executed under
## _config[:knife_user]
##
## A private key string in PEM format for the temporary knife calls the node will make
## _config[:knife_pem]
##
## A hostname string indicating the hostname of the chef client node
## _config[:hostname]
##
## A string indicating the public domain for FQDN
## _config[:public_domain]
##
## A string indicating the client version for the chef client
## _config[:chef_version]
##
## A string indicating the root key used for AWS root key pem
## _config[:key_name]
##
## A string indicating the name of the stack for cloudformation
## _config[:stackname]
##
## A string indicating iam_role to be used by the instance
## _config[:iam_role]
##
## A string indicating the name of the element for cfn-init
## _config[:name]
##
## A string indicating the base ami
## _config[:ami]
##
## A string indicating the instance_type or size such as m3.medium
## _config[:size]
##
## An Array of security groups to apply to the instance
## _config[:security_group_ids]
##
## A string indicating the subnet_id to apply to the instance
## _config[:subnet_id]
##
## A boolean indicating if the node is part of a farm.  if it is the hostname will have the local ipv4 address appended
## _config[:farmed]
#
## HOSTNAME script grabs local ip from amazon and sets the FQDN
#
#if _config[:farmed]
#  mutator = "$HOSTNAME-$IPV4$DOMAIN"
#else
#  mutator = "$HOSTNAME$DOMAIN"
#end
#
## if no _config[:databag_user] specified use root
#if _config[:databag_user]
#  databag_user = _config[:databag_user]
#else
#  _config[:databag_user] = "root"
#end
#
#load_databag_key <<-EOH
#cat<<EOF > /#{databag_user}/.ssh/do-not-delete
##{_config[:chef_databag_key]}
#EOF
#EOH
#
#create_chef_client_rb <<-RUBY
#cat<<EOF > /etc/chef/client.rb
#log_level :info
#log_location /tmp/chef-client-run.log
#chef_server_url #{_config[:chef_server_url]}
#validation_client_name #{_config[:chef_validator_s3_rel]}
#validation_key /etc/chef/validator.pem
#file_backup_path /var/cache/chef
#file_cache_path /var/cache/chef
#client_key /etc/chef/client.pem
#EOF
#RUBY
#
#create_first_run_json <<-EOH
#cat<<EOF > /etc/chef/first-run.json
#{
#  "run_list": "#{_config[:chef_role]}"
#}
#EOF
#EOH
#
#chef_client_first_run <<-EOH
#chef-client -j /etc/chef/first-run.json --environment #{_config[:chef_environment]}
#EOH
#
#create_knife_pem <<-EOH
#cat<<EOF > /tmp/knife.pem
##{_config[:knife_pem]}
#EOH
#
#create_knife_rb <<-EOH
#cat<<EOF > /tmp/knife.rb
#log_level :debug
#client_key /tmp/knife.pem
#node_name #{_config[:knife_user]}
#log_location /tmp/knife-run.log
#chef_server_url #{_config[:chef_server_url]}
#validation_key /etc/chef/validator.pem
#validation_client_name #{_config[:chef_validator_name]}
#EOH
#
#use_knife_to_clear_server_existence <<-EOH
#echo #{knife_destroy_script} > /tmp/knife_destroy.py
#/usr/bin/python /tmp/knife_destroy.py #{mutator}
#EOH
#
## Try to detect the node in the
## server, if found, delete client and node
## representing the server in chef and
## then re-register
#knife_destroy_script <<-PYTHON
##!/bin/env python
#import subprocess
#import shlex
#import sys
#def command(cmd):
#  shlexed = shlex.split(cmd)
#  proc = subprocess.Popen(shlexed, stdout=subprocess.PIPE)
#  out, err = proc.communicate()
#  return out, err
#def write_log(logfile, log_msg):
#  with open(logfile, 'w') as f:
#    f.write(log_msg)
#def log(msg):
#  write_log('/tmp/knife-commands.log', msg)
#def delete_target(target):
#  knife_node_delete = "knife node delete {0} -y".format(target)
#  knife_client_delete = "knife client delete {0} -y".format(target)
#  knife_node_list = "knife node list"
#  node_list = command(knife_node_list)[0].split()
#  if target in node_list:
#    client_delete = command(knife_client_delete)[0]
#    node_delete = command(knife_node_delete)[0]
#    log("this node has been deleted :: {0}".format(target))
#  else:
#    log("this node was not found and knife was not run :: {0}".format(target))
#delete_target(sys.argv[1])
#PYTHON
#
#ec2_hostname_script <<-EOH
##!/bin/env bash
#DOMAIN=#{_config[:public_domain]}
#HOSTNAME=#{_config[:hostname]}
#IPV4=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
#hostname #{mutator}
#echo #{mutator} > /etc/hostname
#cat<<EOF > /etc/hosts
## this file generated by /usr/local/ec2/ec2-hostname.sh
#127.0.0.1  localhost localhost.localdomain localhost4 localhost4.localdomain4
#::1        localhost localhost.localdomain localhost6 localhost6.localdomain6
#$IPV4 #{mutator}
#echo "hostname script has run" >> $ZELOGS
#EOF
#EOH
#
#create_ec2_hostname_script <<-EOH
#cat<<EOF > /usr/local/ec2/ec2-hostname.sh
##{ec2_hostname_script}
#EOF
#EOH
#
#run_hostname_script <<-EOH
#/usr/local/ec2/ec2-hostname.sh
#EOH
#
#omnibus_install <<-EOH
#yum install curl -y
#curl -L https://www.chef.io/chef/install.sh | bash
#EOH
#
#validator_from_s3 <<-EOH
##!/bin/env bash
#VALIDATOR_S3_REL=#{_config[:chef_validator_s3_rel]}
#BUCKET=#{_config[:chef_bucket]}
#RESOURCE="/${BUCKET}/${VALIDATOR_S3_REL}"
#CONTENTTYPE="application/x-compressed-tar"
#DATEVALUE="`date +'%a, %d %b %Y %H:%M%S %z'`"
#STRINGTOSIGN="GET
#${CONTENTTYPE}
#${DATEVALUE}
#${RESOURCE}"
#s3Key=#{_config[:chef_bucket_iam_user_id]}
#s3Secret=#{_config[:chef_bucket_iam_user_key]}
#SIGNATURE=`/bin/echo -n "$STRINGTOSIGN" | openssl sha1 -hmac ${s3Secret} -binary | base64`
#curl -H "Host: ${BUCKET}.s3.amazonaws.com" \
#-H "Date: ${DATEVALUE}" \
#-H "Content-Type: ${CONTENTTYPE}" \
#-H "Authorization: AWS ${s3Key}:${SIGNATURE}" \
#https://${BUCKET}.s3.amazonaws.com/${VALIDATOR_S3_REL} > /etc/chef/validator.pem
#EOH
#
#kill_knife_binary <<-EOH
#rm -rf /usr/bin/knife
#EOH
#
#user_data_magic <<-EOH
##!/bin/env bash
## Easy log file
#ZELOGS=/tmp/hostname-script-activity.log
#touch $ZELOGS
## Install hostname script
#  echo "ec2-hostname.sh was created without deleting it" >> $ZELOGS
#else
#  rm -rf /usr/local/ec2-hostname.sh
#  echo #{ec2_hostname_script} > /usr/local/ec2-hostname.sh
#  echo "ec2-hostname.sh was created and it was deleted from the last one found" >> $ZELOGS
#fi
##{omnibus_install}
##{load_databag_key}
##{create_ec2_hostname_script}
##{run_hostname_script}
##{create_chef_client_rb}
##{create_first_run_json}
##{create_knife_pem}
##{create_knife_rb}
##{validator_from_s3}
##{use_knife_to_clear_server_existence}
##{chef_client_first_run}
##{kill_knife_binary}
#EOH
#
#SparkleFormation.dynamic(:chef_node) do |_name, _config={}|
#  # Configuration SPACE
#  # Configuration SPACE END
#  dynamic!(:ec2_instance, _name) do
#    #camel_keys_set!(:auto_disable)
#    properties do
#      key_name _config[:key_name]
#      user_data <<-EOH
#      #{user_data_magic}
#      EOH
#      availability_zone _config[:az]
#      image_id _config[:ami]
#      instance_type _config[:size]
#      iam_instance_profile _config[:iam_role]
#      security_group_ids _config[:security_group_ids]
#      subnet_id _config[:subnet_id]
#      tags _config[:tags]
#    end
#  end
#end
