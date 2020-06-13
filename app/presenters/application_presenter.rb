class ApplicationPresenter
  include CamelizeKeys
  include StringifyIds

  def initialize(view_context)
    @view = view_context
  end

  def props_to_json
    camelize_keys(stringify_ids(props)).to_json
  end

  private

  attr_reader :view

  delegate(
    :pundit_user,
    :current_user,
    :current_host,
    :current_school,
    :current_founder,
    :current_startup,
    :current_coach,
    :current_school_admin,
    to: :view
  )
end
