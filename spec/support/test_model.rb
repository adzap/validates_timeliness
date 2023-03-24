module TestModel
  extend ActiveSupport::Concern
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::ORM::ActiveModel

  included do
    attribute_method_suffix "="
  end
end

