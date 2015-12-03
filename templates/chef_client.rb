SparkleFormation.new('chef_client') do
  description "A Chef Client"
  parameters do
    hostname do
      type "String"
      default "cheftestnode"
    end
    domain do
      type "String"
      default "anaplan-devops.com."
    end
    private_hosted_zone_id do
      type "String"
      default "Z7VEETB3NASPZ"
    end
    public_hosted_zone_id do
      type "String"
      default "ZQ3EBPCJHKLF6"
    end
    owner do
      type "String"
      default "luis"
    end
    owner_group do
      type "String"
      default "DevOps"
    end
    owner_application do
      type "String"
      default "sparkleformation"
    end
    user_data do
      type "String"
      default <<-EOH
#!/bin/bash
touch /tmp/test1
EOH
    end
    key_name do
      type "AWS::EC2::KeyPair::KeyName"
      default "luis"
    end
    availability_zone do
      type "String"
      default "us-west-1c"
    end
    region do
      type "String"
      default "us-west-1"
    end
    image_id do
      type "AWS::EC2::Image::Id"
      default "ami-d5ea86b5"
    end
    instance_type do
      type "String"
      default "m3.large"
    end
    security_group_ids do
      type "List<AWS::EC2::SecurityGroup::Id>"
      default "sg-93f4d5f6"
    end
    subnet_id do
      type "String"
      default "subnet-10e99f75"
    end
  end
  dynamic!(:ec2_instance, :chef_client) do
    properties do
      user_data base64!(join!("\n",ref!(:user_data)))
      key_name ref!(:key_name)
      availability_zone ref!(:availability_zone)
      image_id ref!(:image_id)
      instance_type ref!(:instance_type)
      security_group_ids ref!(:security_group_ids)
      subnet_id ref!(:subnet_id)
      tags [
        {"Key" => "Name", "Value" => ref!(:hostname)},
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)},
      ]
    end
  end
  dynamic!(:recordset, :chef_client_public) do
    properties do
      name join!(ref!(:hostname),".",ref!(:domain))
      TTL "900"
      type "A"
      hosted_zone_id ref!(:public_hosted_zone_id)
      resource_records [
        attr!(:chef_client_ec2_instance, :public_ip)
      ]
    end
  end
  dynamic!(:recordset, :chef_client_private) do
    properties do
      name join!(ref!(:hostname),".",ref!(:domain))
      TTL "900"
      type "A"
      hosted_zone_id ref!(:private_hosted_zone_id)
      resource_records [
        attr!(:chef_client_ec2_instance, :private_ip)
      ]
    end
  end
  outputs do
    owner do
      value ref!(:owner)
    end
    owner_group do
      value ref!(:owner_group)
    end
    owner_application do
      value ref!(:owner_application)
    end
    user_data_script do
      value ref!(:user_data)
    end
    public_ip do
      value attr!(:chef_client_ec2_instance, :public_ip)
    end
    private_ip do
      value attr!(:chef_client_ec2_instance, :private_ip)
    end
    public_record do
      value ref!(:chef_client_public_recordset)
    end
    private_record do
      value ref!(:chef_client_private_recordset)
    end
  end
end
