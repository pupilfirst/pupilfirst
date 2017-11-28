module UserSessionsHelper
  def hidden_sign_in_class(type, link: false)
    add_class = type == 'federated' ? link : !link
    add_class = !add_class if @sign_in_error
    add_class ? 'd-none' : ''
  end
end
