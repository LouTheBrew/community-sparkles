#SparkleFormation.dynamic(:qa_record) do |_name, _config={}|
#  dynamic!(:r53_record, _name) do
#    properties do
#      name _config(:record_name)
#      comment _config(:record_comment)
#      ttl _config(:record_ttl)
#      type _config(:record_type)
#      hosted_zone_id _config(:record_zone_id)
#      resource_records _config(:record_resource_list)
#    end
#  end
#end
