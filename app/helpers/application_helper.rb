module ApplicationHelper
  def profile_image_url(founder, gravatar_size: 100, avatar_version: :full)
    if founder.avatar?
      if founder.avatar_processing?
        founder.avatar_url
      else
        case avatar_version
          when :thumb
            founder.avatar.thumb.url
          when :mid
            founder.avatar.mid.url
          else
            founder.avatar_url
        end
      end
    else
      founder.gravatar_url(size: gravatar_size, default: 'identicon')
    end
  end

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
end
