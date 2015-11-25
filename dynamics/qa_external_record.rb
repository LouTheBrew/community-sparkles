SparkleFormation.dynamic(:qa_record) do |_name, _config={}|
  dynamic!(:r53_record, _name) do
    properties do
      name nil
      comment nil
      ttl nil
      type nil
      hosted_zone_id nil
      resource_records nil
    end
  end
end
