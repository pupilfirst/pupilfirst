module UsersHelper
  def startup_html(startup)
    if startup.present?
      link_to startup.try(:name), startup_url(startup)
    else
      '<em>Not member of a Startup yet</em>'.html_safe
    end
  end

  def value_or_not_available(value, placeholder: 'Not Available')
    if value.blank?
      "<em>#{placeholder}</em>".html_safe
    else
      value
    end
  end
end
