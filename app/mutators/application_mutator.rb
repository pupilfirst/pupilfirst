class ApplicationMutator
  include ActiveModel::Model

  attr_reader :context

  def initialize(attributes, context)
    @context = context
    assign_attributes(attributes)
  end

  def error_codes
    errors.messages.values.flatten
  end

  def current_user
    context[:current_user]
  end

  def current_school
    context[:current_school]
  end

  def current_school_admin
    context[:current_school_admin]
  end
end
