## Chef and Sparkleformation for Ruby awesomeness... heres how to use this.
## the component takes a component name of _name and a configuration Hash of _config
## The required contents of _config are as follows
##
## An amazon iam user id with sufficient permissions to access the s3 bucket containing chef-client files such as pems and certs
## _config[:chef_bucket_iam_user_id]
##
## A key to go with the user_id
## _config[:chef_bucket_iam_user_key]
##
## An Array type containing names of buckets (usually one) containing information for chef
## _config[:buckets]
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
## A role string in the format of example "role[my_chef_role]"
## _config[:chef_role]
##
## A string indicating the chef environment the node will belong to
## _config[:chef_environment]
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
## A list with the tags for the instance in the cloudformation value format
#
#SparkleFormation.dynamic(:chef_node) do |_name, _config={}|
#  dynamic!(:ec2_instance, _name) do
#    camel_keys_set!(:auto_disable)
#    metadata "AWS::CloudFormation::Authentication" => {
#        :S3ChefClientCredentials => {
#          :type => "S3",
#          :accessKeyId => _config[:chef_bucket_iam_user_id],
#          :secretKey => _config[:chef_bucket_iam_user_key],
#          :buckets => _config[:buckets]
#        }
#      },
#      "AWS::CloudFormation::Init" => {
#        :configSets => {
#          :up => [:hostname_changes, :omnibus_installer, :knife_actions, :load_databag_key, :chef_client_first_run, :kill_knife_binary]
#        },
#        :load_databag_key => {
#          :files => {
#            "/root/.ssh/do_not_delete" => {
#              :content => _config[:chef_databag_key],
#            }
#          }
#        },
#        :kill_knife_binary => {
#          :commands => {
#            :kill_knife => {
#              :command => ["rm -rf", "/usr/bin/knife"],
#              :cwd => "/tmp/"
#            }
#          }
#        },
#        :chef_client_first_run => {
#          :files => {
#            "/etc/chef/client.rb" => {
#              :content => _config[:knife_config]
#            },
#            "/etc/chef/validator.pem" => {
#              :source => "http://s3.amazonaws.com/#{_config[:chef_bucket_name]}/#{_config[:validation_client_s3_rel]}",
#              :authentication => "S3ChefClientCredentials",
#              :mode => "000666",
#              :owner => "root",
#              :group => "root"
#            },
#            "/etc/chef/first-run.json" => {
#              :content => <<-EOH
#              {
#                "run_list": "#{_config[:chef_role]}"
#              }
#              EOH
#            }
#          },
#          :commands => {
#            :client_run => {
#              :command => ["chef-client", "-j", "/etc/chef/first-run.json", "--environment", _config[:chef_environment]],
#              :cwd => "/tmp/"
#            }
#          }
#        },
#        :knife_actions => {
#          :files => {
#            "/tmp/destroy_knife_target.py" => {
#              :content => <<-PYTHON
#              #!/bin/env python
#              import subprocess
#              import shlex
#              import sys
#              def command(cmd):
#                shlexed = shlex.split(cmd)
#                proc = subprocess.Popen(shlexed, stdout=subprocess.PIPE)
#                out, err = proc.communicate()
#                return out, err
#              def write_log(logfile, log_msg):
#                with open(logfile, 'w') as f:
#                  f.write(log_msg)
#              def log(msg):
#                write_log('/tmp/knife-commands.log', msg)
#              def delete_target(target):
#                knife_node_delete = "knife node delete {0} -y".format(target)
#                knife_client_delete = "knife client delete {0} -y".format(target)
#                knife_node_list = "knife node list"
#                node_list = command(knife_node_list)[0].split()
#                if target in node_list:
#                  client_delete = command(knife_client_delete)[0]
#                  node_delete = command(knife_node_delete)[0]
#                  log("this node has been deleted:: {0}".format(target))
#                else:
#                  log("this node was not found and knife was not run :: {0}".format(target))
#              delete_target(sys.argv[1])
#              PYTHON
#            },
#            "/tmp/knife.pem": {
#              :content => _config[:knife_pem]
#            },
#            "/tmp/knife.rb": {
#              :content => _config[:knife_config]
#            }
#          },
#          :commands => {
#            :delete => {
#              :command => ["/usr/bin/knife", "/tmp/destroy_knife_target.py", "#{_config[:hostname]}#{_config[:public_domain]}"],
#              :cwd => "/tmp/"
#            }
#          }
#        },
#        :hostname_changes => {
#          :files => {
#            "/usr/local/ec2/ec2-hostname.sh": {
#              :mode => "000777",
#              :content => <<-EOH
#              DOMAIN=#{_config[:public_domain]}
#              HOSTNAME=#{_config[:hostname]}
#              IPV4=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
#              hostname $HOSTNMAE$DOMAIN
#              echo #HOSTNAME > /etc/hostname
#              cat<<EOF > /etc/hosts
#              # this file generated by /usr/local/ec2/ec2-hostname.sh
#              127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
#              ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
#              $IPV4 $HOSTNAME$DOMAIN
#              EOF
#              EOH
#            }
#          }
#        },
#        :omnibus_installer => {
#          :files => {
#            "/tmp/install.sh" => {
#              :source => "https://www.opscode.com/chef/install.sh",
#              :mode => "000777",
#              :owner => "root",
#              :group => "root"
#            }
#          },
#          :commands => {
#            :client_install => {
#              :command => ["/bin/bash", "/tmp/install.sh", "-v", _config[:chef_version]],
#              :cwd => "/tmp/"
#            }
#          }
#        }
#      }
#    properties do
#      key_name _config[:key_name]
#      user_data <<-EOH
#      #!/bin/bash -xe
#      echo /usr/local/ec2/ec2-hostname.sh >> /etc/rc.local
#      yum install wget -y
#      wget https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
#      tar xvzf aws-cfn-bootstrap-latest.tar.gz
#      cd aws-cfn-bootstrap*
#      python setup.py install
#      cfn-init --stack #{_config[:stackname]} --region #{_config[:region]} --role #{_config[:iam_role]} --configsets up --resource #{_config[:name]}
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
