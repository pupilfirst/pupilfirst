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

  def dashboard_or_root_url
    current_founder&.startup.present? ? dashboard_founder_url : root_url
  end

  def short_url(full_url, expires_at: nil)
    ShortenedUrls::ShortenService.new(full_url, expires_at: expires_at).short_url
  end

  def show_pending_payment_notice
    !current_page?(fee_founder_path) && !current_startup&.level_zero? && current_startup&.payments&.pending&.any?
  end
end
