module ApplicationHelper
  def founder_roles(roles)
    if roles.blank?
      '<em>No Role Selected</em>'.html_safe
    else
      roles.map do |role|
        t("role.#{role}")
      end.join ', '
    end
  end

  def dashboard_or_root_url
    current_founder&.startup.present? ? dashboard_founder_url : root_url
  end

  def short_url(full_url, expires_at: nil)
    ShortenedUrls::ShortenService.new(full_url, expires_at: expires_at).short_url
  end
end
