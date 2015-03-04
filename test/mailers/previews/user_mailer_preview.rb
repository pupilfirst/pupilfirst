require 'mailer_preview_helper'

class UserMailerPreview < ActionMailer::Preview
  def confirm_partnership_formation
    partnership = FactoryGirl.create :partnership
    UserMailer.confirm_partnership_formation(partnership, partnership.startup.founders.first)
    partnership.destroy!
  end
end
