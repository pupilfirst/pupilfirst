module ApplicationHelper
  def fmt_time(t)
    fail(ArgumentError, "Should be a instance of Time/Date/DateTime. #{t.class} given.") unless t.is_a?(Time) || t.is_a?(Date) || t.is_a?(DateTime)
    t.strftime('%F %R%z')
  end

  def profile_image_url(user, gravatar_size: 100, avatar_version: :full)
    if user.avatar?
      case avatar_version
        when :thumb
          user.avatar.thumb.url
        when :mid
          user.avatar.mid.url
        else
          user.avatar_url
      end
    else
      user.gravatar_url(size: gravatar_size, default: 'identicon')
    end
  end

  def founder_roles(roles)
    if roles.blank?
      '<em>No Role Selected</em>'.html_safe
    else
      roles.map do |role|
        t("user.#{role}")
      end.join ', '
    end
  end
end
