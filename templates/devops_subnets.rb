SparkleFormation.new('devops_subnets') do
  description "A series of subnets"
  parameters do
    public_cidr_block do
      type "String"
      default "10.1.1.0/24"
    end
    private_cidr_block do
      type "String"
      default "10.1.254.0/24"
    end
    vpc_id do
      type "String"
    end
  end
  dynamic!(:subnet, :private) do
    properties do
      availability_zone ref!(:availability_zone)
      cidr_block ref!(:private_cidr_block)
      vpc_id ref!(:vpc_id)
    end
  end
  dynamic!(:subnet, :public) do
    properties do
      availability_zone ref!(:availability_zone)
      cidr_block ref!(:public_cidr_block)
      vpc_id ref!(:vpc_id)
      map_public_ip_on_launch true
    end
  end
end
