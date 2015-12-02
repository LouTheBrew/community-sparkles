SparkleFormation.new('devops_vpc') do
  description "DevOps network"
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
    cidr_block do
      type "String"
      default "10.1.0.0/16"
    end
    availability_zone do
      type "String"
      default "us-west-1c"
    end
  end
  dynamic!(:ec2_vpc, :sparkleformation_testing) do
    properties do
      cidr_block ref!(:cidr_block)
      tags [
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)},
      ]
    end
  end
  dynamic!(:internet_gateway, :sparkleformation_testing) do
    properties do
      tags [
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)},
      ]
    end
  end
  dynamic!(:vpc_gateway_attachment, :sparkleformation_testing) do
    properties do
      internet_gateway_id ref!(:sparkleformation_testing_internet_gateway)
      vpc_id ref!(:sparkleformation_testing_ec2_vpc)
    end
  end
  dynamic!(:subnet, :sparkleformation_testing) do
    properties do
      availability_zone ref!(:availability_zone)
      cidr_block "10.1.1.0/24"
      vpc_id ref!(:sparkleformation_testing_ec2_vpc)
      map_public_ip_on_launch true
    end
  end
  outputs do
    sparkleformation_subnet_id do
      value ref!(:sparkleformation_testing_subnet)
    end
    sparkleformation_vpc_id do
      value ref!(:sparkleformation_testing_ec2_vpc)
    end
  end
end
