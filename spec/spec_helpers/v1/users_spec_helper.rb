require_relative 'api_spec_helper'
require_relative 'startups_spec_helper'

module UserSpecHelper
  include ApiSpecHelper
  include StartupsSpecHelper

  def have_user_object(response, prefix = '', opt = {})
    opt[:also_check] ||= []
    opt[:ignore] ||= []
    prefix = if prefix.present?
      prefix[-1] == '/' ? prefix : "#{prefix}/"
    end
    check_path(response, "#{prefix}id")
    check_type(response, "#{prefix}id",Integer)
    check_path(response, "#{prefix}fullname")
    check_path(response, "#{prefix}avatar_url")
    check_path(response, "#{prefix}auth_token") if opt[:also_check].include?(:auth_token)
    check_path(response, "#{prefix}phone") if opt[:also_check].include?(:phone)
    check_path(response, "#{prefix}phone_verified") if opt[:also_check].include?(:phone_verified)
    have_startup_object(response,"#{prefix}startup") unless opt[:ignore].include?(:startup)
  end
end
