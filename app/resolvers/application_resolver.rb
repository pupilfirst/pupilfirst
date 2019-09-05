class ApplicationResolver
  include ActiveModel::Model
  attr_reader :context

  def initialize(context)
    @context = context
  end

  def current_school_admin
    context[:current_school_admin]
  end

  def current_school
    context[:current_school]
  end

  def current_user
    context[:current_user]
  end

  # current_school: current_school,
  # current_founder: current_founder,
  # current_coach: current_school,
  # current_domain: current_domain,
  # current_host: current_host,
  # current_startup: current_startup,
  # current_school_admin: current_school_admin
end
