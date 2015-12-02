SparkleFormation.new('qa') do
  description "Create a QA environment, 2 cores 1 of each service"
  parameters do
    region do
      type "String"
    end
    developer do
      type "String"
    end
    iam_role do
      type "String"
    end
    subnet do
      type "String"
    end
    public_zone_id do
      type "String"
    end
    private_zone_id do
      type "String"
    end
    public_domain do
      type "String"
    end
    private_domain do
      type "String"
    end
    key_name do
      type "String"
    end
    base_ami do
      type "String"
    end
    security_group do
      type "String"
    end
      type "String"
    end
    zone do
      type "String"
    end
    sdp1_hostname do
      type "String"
    end
    api1_hostname do
      type "String"
    end
    glue1_hostname do
      type "String"
    end
    core1_hostname do
      type "String"
    end
    core2_hostname do
      type "String"
    end
    sdp1_size do
      type "String"
    end
    api1_size do
      type "String"
    end
    glue1_size do
      type "String"
    end
    core1_size do
      type "String"
    end
    core2_size do
      type "String"
    end
    sdp1_role do
      type "String"
    end
    api1_role do
      type "String"
    end
    glue1_role do
      type "String"
    end
    core1_role do
      type "String"
    end
    core2_role do
      type "String"
    end
    chef_environment do
      type "String"
    end
    chef_version do
      type "String"
    end
    chef_server_url do
      type "String"
    end
    chef_validation_client_name do
      type "String"
    end
    chef_validation_key_s3_rel do
      type "String"
    end
    chef_bucket_iam_user_id do
      type "String"
    end
    chef_bucket_iam_user_key do
      type "String"
    end
    chef_bucket_name do
      type "String"
    end
    chef_knife_pem do
      type "String"
    end
    chef_knife_user do
      type "String"
    end
    databag_key <<-EOH
    lcypRWHQiRmRufrJiVpFl5Z5k8qaI8Fgz2zsuYhLwcXbHMl3pDsyiUzYrAYNx/
    iWCxiBw9+iv5RSItu4wswH
    +sbDiEK2JbI8jDDVjFroxih8cL9nHzHwTQlRQxMYYiWvUWMJzRKOHgcJAltxK7XJOs/
    cakG3155lkSSaY/JQPTZiQaP5CsAX6DcIF6JAUpjCLJ2Rpph3/W6yxGa9wjCO/
    zS06DnzXCCwDJ3Oien5JdafH0LhMNOYBQo9mJOwkQdwiY03mH
    +SdBqEMwoOt1TP2okBvXcN9szDezNotKSOJ6vV0nc9p57rXojP0NF8CDVj/OM2GiX4o
    +E0DgYJ86xNeRcdYPCP8+KNCZ/0TToAqd9vd32FmXabvYSYrh7f6MXaRnrKL/Cb/
    9Az74u6oGyxXhw2KKmesZkyTRn4d
    +VxD9Cuu1ESaf7HYDKswO5wRxoMbLwwLTgzxhOc3kwG1H6W0iYkcxVGuXicgjWDuNNrH9sV9GIg4YJZv
    tj1L0D2mrK31xDr9QI3DdgB5dYLSuBv1mNxSnv
    +i1r1izYV0dI0WEazAzBMwpNxspJuxHQMngZ8CnX5QHpyLWTO3Or5qhbzSXPq8pHZMQQcuFP3zPPsXuy
    U7j/vFYOGUo8t07w139KC+j2ThNSbDaA3sCoTn7PVUeEW7lQ0v397ainEbRfFQOs=
    EOH
    knife_config <<-RUBY
    log_level :info
    log_location /tmp/chef-client-run.log
    chef_server_url #{ref!(:chef_server_url)}
    validation_client_name #{ref!(:chef_validation_client_name)}
    validation_key /etc/chef/validator.pem
    file_backup_path /var/cache/chef
    file_cache_path /var/cache/chef
    client_key /etc/chef/client.pem
    RUBY
    [
      {
        :name => "core1",
        :config => {
          # DNS STUFF
          :record_name => ref!(:core1_hostname),
          :record_ttl => "900",
          :record_type => "A",
          :record_comment => "DNS core1 record",
          :record_zone_id => ref!(:public_zone_id),
          :record_resource_list => [attr!("core1", "PublicIp")],
          # DNS STUFF END
          :stackname => ref!("AWS::StackName"),
          :region => ref!(:region),
          :size => ref!(:core1_size),
          :az => ref!(:zone),
          :tags => [
            {"Key" => "Name", "Value" => "#{ref!(:core1_hostname)}#{ref!(:public_domain)}"},
            {"Key" => "Developer", "Value" => "#{ref!(:developer)}"}
          ],
          :subnet_id => ref!(:subnet),
          :security_group_ids => [ref!(:security_group)],
          :hostname => ref!(:core1_hostname),
          :iam_role => ref!(:iam_role),
          :private_domain  => ref!(:private_domain),
          :public_domain => ref!(:public_domain),
          :private_zone_id => ref!(:private_zone_id),
          :public_zone_id => ref!(:public_zone_id),
          :developer => ref!(:developer),
          :ami => ref!(:base_ami),
          :key_name => ref!(:key_name),
          :knife_config => knife_config,
          :knife_pem => ref!(:chef_knife_pem),
          :buckets => [ref!(:chef_bucket_name)],
          :chef_role => ref!(:core1_role),
          :chef_environment => ref!(:chef_environment),
          :chef_client_bucket_name => ref!(:chef_bucket_name),
          :validation_client_s3_rel => ref!(:chef_validation_key_s3_rel),
          :chef_databag_key => databag_key,
          :chef_bucket_iam_user_id => ref!(:chef_bucket_iam_user_id),
          :chef_bucket_iam_user_key => ref!(:chef_bucket_iam_user_key)
        }
      }
    ].each do |profile|
      dynamic!(:chef_node, profile[:name], profile[:config])
      #dynamic!(:qa_internal_record_set, profile[:name], profile[:config])
      #dynamic!(:qa_external_record_set, profile[:name], profile[:config])
    end
    #dynamic!(:chef_node, :core1)
    #dynamic!(:ec2_instance, :glue1) do
    #  properties do
    #    key_name "luis"
    #  end
    #end

  #mappings.region_map do
  #  set!('us-east-1'._no_hump, :ami => 'ami-7f418316')
  #  set!('us-west-1'._no_hump, :ami => 'ami-951945d0')
  #  set!('us-west-2'._no_hump, :ami => 'ami-16fd7026')
  #  set!('eu-west-1'._no_hump, :ami => 'ami-24506250')
  #  set!('sa-east-1'._no_hump, :ami => 'ami-3e3be423')
  #  set!('ap-southeast-1'._no_hump, :ami => 'ami-74dda626')
  #  set!('ap-northeast-1'._no_hump, :ami => 'ami-dcfa4edd')
  #end

  #dynamic!(:ec2_instance, :my) do
  #  properties do
  #    key_name ref!(:key_name)
  #    image_id map!(:region_map, region!, :ami)
  #    user_data base64!('80')
  #  end
  #end

  #outputs do
  #  instance_id do
  #    description 'InstanceId of the newly created EC2 instance'
  #    value ref!(:my_ec2_instance)
  #  end
  #  az do
  #    description 'Availability Zone of the newly created EC2 instance'
  #    value attr!(:my_ec2_instance, :availability_zone)
  #  end
  #  public_ip do
  #    description 'Public IP address of the newly created EC2 instance'
  #    value attr!(:my_ec2_instance, :public_ip)
  #  end
  #  private_ip do
  #    description 'Private IP address of the newly created EC2 instance'
  #    value attr!(:my_ec2_instance, :private_ip)
  #  end
  #  public_dns do
  #    description 'Public DNSName of the newly created EC2 instance'
  #    value attr!(:my_ec2_instance, :public_dns_name)
  #  end
  #  private_dns do
  #    description 'Private DNSName of the newly created EC2 instance'
  #    value attr!(:my_ec2_instance, :private_dns_name)
  #  end
  #end
end
