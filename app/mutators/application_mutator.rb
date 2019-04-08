class ApplicationMutator
  include ActiveModel::Model

  attr_reader :context

  validate :must_be_authorized

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
