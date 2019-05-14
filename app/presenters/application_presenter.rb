class ApplicationPresenter
  include CamelizeKeys

  def initialize(view_context)
    @view = view_context
  end

  private

  attr_reader :view

  delegate(
    :current_user,
    :current_host,
    :current_domain,
    :current_school,
    :current_founder,
    :current_startup,
    :current_coach,
    to: :view
  )
end
