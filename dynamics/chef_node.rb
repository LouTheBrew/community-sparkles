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
      "AWS::CloudFormation::Init": {
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
        :kill_knife_binary => {:commands => {:command ["rm -rf", "/usr/bin/knife"], :cwd => "/tmp/"}},
        #:kill_knife_binary => {}
        #:hostname_changes
        #:omnibus_installer
        #:knife_actions
        #:chef_client_first_run
        #:kill_knife_binary
      }
    properties do
      key_name _config[:key_name]
    end
  end
end
