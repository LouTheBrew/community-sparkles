SparkleFormation.new('devops_vpc') do
  description "DevOps Testing Network"
  parameters do
    domain do
      type "String"
      default "anaplan-devops.com."
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
    vpc_cidr_block do
      type "String"
      default "10.1.0.0/16"
    end
    availability_zone do
      type "String"
      default "us-west-1c"
    end
    region do
      type "String"
      default "us-west-1"
    end
  end
  dynamic!(:ec2_vpc, :sparkleformation_testing) do
    properties do
      cidr_block ref!(:vpc_cidr_block)
      enable_dns_support true
      enable_dns_hostnames true
      instance_tenancy "default"
      tags [
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)}
      ]
    end
  end
  dynamic!(:internet_gateway, :sparkleformation_testing) do
    properties do
      tags [
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)}
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
  dynamic!(:route_table, :sparkleformation_testing) do
    properties do
      vpc_id ref!(:sparkleformation_testing_ec2_vpc)
      tags [
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)}
      ]
    end
  end
  dynamic!(:subnet_route_table_association, :sparkleformation_testing) do
    properties do
      route_table_id ref!(:sparkleformation_testing_route_table)
      subnet_id ref!(:sparkleformation_testing_subnet)
    end
  end
  dynamic!(:route, :sparkleformation_testing) do
    depends_on "SparkleformationTestingRouteTable"
    properties do
      gateway_id ref!(:sparkleformation_testing_internet_gateway)
      route_table_id ref!(:sparkleformation_testing_route_table)
      destination_cidr_block "0.0.0.0/0"
    end
  end
  dynamic!(:hosted_zone, :sparkleformation_testing_public) do
    properties do
      name ref!(:domain)
      hosted_zone_config "Comment" => "A private hosted zone for devops testing"
      hosted_zone_tags [
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)}
      ]
      VPCs [
        {"VPCId" => ref!(:sparkleformation_testing_ec2_vpc), "VPCRegion" => ref!(:region)}
      ]
    end
  end
  dynamic!(:hosted_zone, :sparkleformation_testing_private) do
    properties do
      name ref!(:domain)
      hosted_zone_config "Comment" => "A public hosted zone for devops testing"
      hosted_zone_tags [
        {"Key" => "Owner", "Value" => ref!(:owner)},
        {"Key" => "OwnerGroup", "Value" => ref!(:owner_group)},
        {"Key" => "OwnerApplication", "Value" => ref!(:owner_application)}
      ]
      # A hosted zone is public implicitly when you do not specify a VPC list
      # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-route53-hostedzone.html
      #vpcs [
      #  {"VPCId" => ref!(:sparkleformation_testing_ec2_vpc), "VPCRegion" => ref!(:region)}
      #]
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
    sparkleformation_subnet_id do
      value ref!(:sparkleformation_testing_subnet)
    end
    sparkleformation_vpc_id do
      value ref!(:sparkleformation_testing_ec2_vpc)
    end
    public_hosted_zone_id do
      value ref!(:sparkleformation_testing_public_hosted_zone)
    end
    private_hosted_zone_id do
      value ref!(:sparkleformation_testing_private_hosted_zone)
    end
  end
end
