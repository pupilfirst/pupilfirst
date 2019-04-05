class ApplicationPresenter
  def initialize(view_context)
    @view = view_context
  end

  protected

  attr_reader :view

  delegate(
    :current_user,
    :current_host,
    :current_domain,
    :current_school,
    :current_founder,
    :current_startup,
    :current_coach,
    :current_school_admin,
    to: :view
  )
end
