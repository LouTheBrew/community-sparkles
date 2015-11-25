SparkleFormation.dynamic(:chef_node) do |_name, _config={}|
  dynamic!(:ec2_instance, _name) do
    camel_keys_set!(:auto_disable)
    metadata "AWS::CloudFormation::Authentication" => {
        :S3ChefClientCredentials => {
          :type => "S3",
          :accessKeyId => _config[:chef_bucket_iam_user_id],
          :secretKey => _config[:chef_bucket_iam_user_key],
          :buckets => _config[:buckets]
        }
      },
      "AWS::CloudFormation::Init" => {
        :configSets => {
          :up => [:hostname_changes, :omnibus_installer, :knife_actions, :load_databag_key, :chef_client_first_run, :kill_knife_binary]
        },
        :load_databag_key => {
          :files => {
            "/root/.ssh/do_not_delete" => {
              :content => _config[:chef_databag_key],
            }
          }
        },
        :kill_knife_binary => {
          :commands => {
            :kill_knife => {
              :command => ["rm -rf", "/usr/bin/knife"],
              :cwd => "/tmp/"
            }
          }
        },
        :chef_client_first_run => {
          :files => {
            "/etc/chef/client.rb" => {
              :content => _config[:knife_config]
            },
            "/etc/chef/validator.pem" => {
              :source => _config[:knife_config]
              :authentication => _config[:knife_config]
              :mode => _config[:knife_config]
              :owner => _config[:knife_config]
              :group => _config[:knife_config]
            },
            "/etc/chef/first-run.json" => {
              :content => _config[:knife_config]
            }
          },
          :commands => {
            :client_run: {
              :command => ["chef-client", "-j", "/etc/chef/first-run.json", "--environment", _config[:chef_environment]],
              :cwd => "/tmp/"
            }
          }
        },
        :knife_actions => {
          :files => {
            "/tmp/destroy_knife_target.py" => {
              :content => _config[:knife_killer_script]
            },
            "/tmp/knife.pem": {
              :content => _config[:knife_pem]
            },
            "/tmp/knife.rb": {
              :content => _config[:knife_rb]
            }
          },
          :commands => {
            :delete => {
              :command => ["/usr/bin/knife", "/tmp/destroy_knife_target.py", "#{_config[:hostname]}#{_config[:domain]}"],
              :cwd => "/tmp/"
            }
          }
        },
        :hostname_changes => {
          :files => {
            "/usr/local/ec2/ec2-hostname.sh": {
              :content => _config[:hostname_script]
              :mode => "000777"
            }
          }
        },
        :omnibus_installer => {
          :files => {
            "/tmp/install.sh" => {
              :source => "https://www.opscode.com/chef/install.sh",
              :mode => "000777",
              :owner => "root",
              :group => "root"
            }
          },
          :commands => {
            :client_install => {
              :command => ["/bin/bash", "/tmp/install.sh", "-v", _config[:chef_version]],
              :cwd => "/tmp/"
            }
          }
        }
      }
    properties do
      key_name _config[:key_name]
      user_data _config[:cfn_strap]
      availability_zone _config[:cfn_strap]
      image_id _config[:ami]
      instance_type _config[:size]
      iam_instance_profile _config[:iam_role]
      security_group_ids _config[:security_group_ids]
      subnet_id _config[:subnet_id]
      tags _config[:tags]
    end
  end
end
