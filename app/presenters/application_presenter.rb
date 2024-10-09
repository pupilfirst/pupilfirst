class ApplicationPresenter
  include CamelizeKeys
  include StringifyIds

  def initialize(view_context)
    @view = view_context
  end

  def props_to_json
    camelize_keys(stringify_ids(props_with_toggles)).to_json
  end

  private

  def props_with_toggles
    props.merge(enabled_features: enabled_features)
  end

  def enabled_features
    return [] unless current_user

    Flipper.features.filter_map { |f| f.name if f.enabled?(current_user) }
  end

  attr_reader :view

  delegate(
    :params,
    :pundit_user,
    :current_user,
    :current_host,
    :current_school,
    :current_startup,
    :current_coach,
    :current_school_admin,
    to: :view
  )
end
