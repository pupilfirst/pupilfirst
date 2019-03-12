module ApplicationHelper
  def founder_roles(roles)
    if roles.blank?
      '<em>No Role Selected</em>'.html_safe
    else
      roles.map do |role|
        t("models.founder.role.#{role}")
      end.join ', '
    end
  end

  def short_url(full_url, expires_at: nil)
    ShortenedUrls::ShortenService.new(full_url, expires_at: expires_at).short_url
  end
end
