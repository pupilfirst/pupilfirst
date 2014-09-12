require_relative 'v1_api_helper'

module StartupSpecHelper
  include V1ApiSpecHelper

  def have_startup_object(response, prefix = '', opt = {})
    opt[:also_check] ||= []
    opt[:ignore] ||= []

    unless prefix.empty?
      prefix = prefix[-1] == '/' ? prefix : "#{prefix}/"
    end

    check_path(response, "#{prefix}id")
    check_type(response, "#{prefix}id",Integer)
    check_path(response, "#{prefix}name")
    check_path(response, "#{prefix}logo_url")
    check_path(response, "#{prefix}pitch")
    check_path(response, "#{prefix}website")
    check_path(response, "#{prefix}about")
    check_path(response, "#{prefix}email")
    check_path(response, "#{prefix}phone")
    check_path(response, "#{prefix}twitter_link")
    check_path(response, "#{prefix}facebook_link")
    check_path(response, "#{prefix}categories")
    check_path(response, "#{prefix}categories_v2")
    check_path(response, "#{prefix}created_at")
    check_path(response, "#{prefix}founders")
    check_path(response, "#{prefix}founders/0/id")
    check_path(response, "#{prefix}founders/0/title")
    check_path(response, "#{prefix}founders/0/name")
    check_path(response, "#{prefix}founders/0/picture_url")
    check_path(response, "#{prefix}founders/0/linkedin_url")
    check_path(response, "#{prefix}founders/0/twitter_url")
  end
end
