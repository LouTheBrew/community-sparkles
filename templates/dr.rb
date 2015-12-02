#SparkleFormation.new('dr') do
#  description "Translating DR plan to cfn"
#  parameters do
#    whatever do
#      type "String"
#    end
#  dynamic!(:chef_node, "core1", {
#    :cloudformation => {
#      :stack => {
#        :name => nil
#      }
#    }
#    :system => {
#      :farmed => nil,
#      :hostname => nil,
#    },
#    :chef => {
#      :databag => {
#        :user => nil,
#        :key_str => nil
#      },
#      :knife => {
#        :s3_validation_key_path => nil,
#        :config_str => nil,
#        :user => nil,
#        :pem_str => nil
#      },
#      :environment => nil,
#      :role => nil,
#      :validator => {
#        :name => nil
#      }
#      :s3 => {
#        :bucket => {
#          :name => nil
#          :iam => {
#            :key => nil,
#            :user => nil
#          }
#        }
#      }
#    }
#    :ec2 => {
#      :size => nil,
#      :ami => nil,
#      :security_group_ids => nil,
#      :subnet_id => nil,
#      :iam => {
#        :role => nil,
#      },
#      :tags => [
#        {"Key" => nil, "Value" => nil}
#      ]
#    }
#  })
#  end
#end
