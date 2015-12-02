SparkleFormation.new('chef_client') do
  description "A Base Chef Client"
  parameters do
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
    hostname do
      type "String"
      default "chef_test_node"
    end
    user_data do
      type "String"
      default <<-EOH
echo "IDONTBELIEVE IN ANYTHING ANYMORE MAN!!!!!" > /tmp/test1
echo "IDONTBELIEVE IN ANYTHING ANYMORE MAN!!!!!" > /tmp/test2
echo "IDONTBELIEVE IN ANYTHING ANYMORE MAN!!!!!" > /tmp/test3
echo "IDONTBELIEVE IN ANYTHING ANYMORE MAN!!!!!" > /tmp/test4
echo "IDONTBELIEVE IN ANYTHING ANYMORE MAN!!!!!" > /tmp/test5
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
      default "sg-02755467"
    end
    subnet_id do
      type "String"
      default "subnet-b04b3dd5"
    end
  end
  dynamic!(:ec2_instance, :chef_client) do
    properties do
      user_data base64!(join!("\n",ref!(:user_data)))
      #user_data ref!(:user_data)
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
  outputs do
    user_data_script do
      #value attr!(:chef_client_ec2_instance, :user_data)
      value ref!(:user_data)
    end
    public_ip do
      #value attr!(:chef_client_ec2_instance, :user_data)
      value ref!(:user_data)
    end
    private_ip do
      #value attr!(:chef_client_ec2_instance, :user_data)
      value ref!(:user_data)
    end
  end
end
