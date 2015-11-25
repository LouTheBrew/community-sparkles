SparkleFormation.new('qa') do
  #description "AWS CloudFormation Sample Template EC2InstanceSample..."
  parameters do
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
    #dynamic!(:chef_node, :key_name => "luis")
    #[
    #  :name => "core1",
    #  :hostname => "core1",
    #  :private_domain  => "core1",
    #  :public_domain => "core1",
    #  :developer => "core1",
    #  :ami => "core1",
    #  :key_name => "core1",
    #  :chef_role => "core1",
    #  :chef_databag_key => "core1",
    #  :chef_bucket_iam_user_id => "core1",
    #  :chef_bucket_iam_user_key => "core1",
    #]

    [:core1, :core2, :glue1, :api1, :sdp1].each do |inst_name|
      dynamic!(:chef_node, inst_name, :key_name => "luis")
      # external
      dynamic!(:qa_record, inst_name, :key_name => "luis")
      # internal
      dynamic!(:qa_record, inst_name, :key_name => "luis")
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
