module TestModel
  extend ActiveSupport::Concern
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods

  included do
    attribute_method_suffix ""
    attribute_method_suffix "="
    cattr_accessor :model_attributes
  end

  module ClassMethods
    def attribute(name, type)
      self.model_attributes ||= {}
      self.model_attributes[name] = type
    end

    def define_method_attribute=(attr_name)
      generated_attribute_methods.module_eval("def #{attr_name}=(new_value); @attributes['#{attr_name}']=self.class.type_cast('#{attr_name}', new_value); end", __FILE__, __LINE__)
    end

    def define_method_attribute(attr_name)
      generated_attribute_methods.module_eval("def #{attr_name}; @attributes['#{attr_name}']; end", __FILE__, __LINE__)
    end

    def type_cast(attr_name, value)
      return value unless value.is_a?(String)
      value.send("to_#{model_attributes[attr_name.to_sym]}") rescue nil
    end
  end

  def initialize(attributes = nil)
    @attributes = self.class.model_attributes.keys.inject({}) do |hash, column|
      hash[column.to_s] = nil
      hash
    end
    self.attributes = attributes unless attributes.nil?
  end

  def attributes
    @attributes
  end

  def attributes=(new_attributes={})
    new_attributes.each do |key, value|
      send "#{key}=", value
    end
  end

  def method_missing(method_id, *args, &block)
    if match_attribute_method?(method_id.to_s)
      self.class.define_attribute_methods self.class.model_attributes.keys
      send(method_id, *args, &block)
    else
      super
    end
  end
end

