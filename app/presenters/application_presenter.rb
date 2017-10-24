class ApplicationPresenter
  def initialize(view_context)
    @view = view_context
  end

  protected

  attr_reader :view
end
