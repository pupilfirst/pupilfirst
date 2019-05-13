class ApplicationPresenter
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

  def camelize_keys(hash)
    hash.deep_transform_keys { |k| k.to_s.camelize(:lower) }
  end
end
