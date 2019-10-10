class ApplicationResolver
  include ActiveModel::Model

  attr_reader :context

  def initialize(context, args = {})
    @context = context
    assign_attributes(args)
    raise UnauthorizedQueryException unless authorized?
  end

  # TODO: Use the same method that ApplicationMutator uses - avoid duplication when doing so.
  def current_school_admin
    context[:current_school_admin]
  end

  def current_school
    context[:current_school]
  end

  def current_user
    context[:current_user]
  end

  def authorized?
    raise 'Please implement the "authorized?" method in the resolver class.'
  end
end
