require_relative 'v1_api_helper'
require_relative 'startup_spec'

module UserSpecHelper
  include V1ApiSpecHelper
  include StartupSpecHelper

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
