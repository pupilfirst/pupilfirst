module ActiveAdmin::ConnectionHelper
  def name_link(user)
    link_to "#{user.fullname} (#{user.phone.present? ? user.phone : user.email})", user
  end
end
