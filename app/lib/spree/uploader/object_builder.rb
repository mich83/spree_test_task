# Utility class to build record object based on attributes structure
class Spree::Uploader::ObjectBuilder
  def initialize(item, errors)
    @item = item
    @errors = errors
  end

  def build(item_attributes)
    recursive_build(@item, item_attributes)
    validate_item
    @item
  end

  def validate_item
    @errors.push(@item.errors.full_messages) unless @item.valid? # and validate
  rescue RuntimeError => err
    @errors.push(err.message)
  end


  def assign_relation_many(item, dependent_key, dependent_value)
    dependent_value.each do |value|
      dependent_item = item.send(dependent_key).build
      recursive_build(dependent_item, value)
    end
  end

  def assign_relation_one(item, dependent_key, dependent_value)
    dependent_item = item.send("build_#{dependent_key}")
    recursive_build(dependent_item, dependent_value)
  end

  def assign_dependent_attributes(item, dependent)
    dependent.each do |dependent_key_value|
      dependent_key, dependent_value = *dependent_key_value
      dependent_key = dependent_key.to_s.remove('_attributes')
      if dependent_value.is_a? Array # if array given we should invoke item.relations.build for each array element (has_many relation)
        assign_relation_many(item, dependent_key, dependent_value)
      else # if hash given we should invoke item.build_relation (has_one relation)
        assign_relation_one(item, dependent_key, dependent_value)
      end
    end
  end

  # recursively builds ActiveRecord object
  # If structure key ends on _attributes it is supposed that association attributes are given
  def recursive_build(item, item_attributes)
    dependent, attrs = item_attributes.partition { |key, _| key.to_s.end_with?('_attributes') }  # split given to own and of associated relations
    # dependent relations processing
    assign_dependent_attributes(item, dependent)
    # assign own attributes
    item.assign_attributes(Hash[attrs])
  end

end