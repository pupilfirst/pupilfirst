# encoding: utf-8
# frozen_string_literal: true

class AdminUser < ApplicationRecord
  TYPE_SUPERADMIN = 'superadmin'
  TYPE_FACULTY = 'faculty'

  belongs_to :faculty, optional: true
  belongs_to :user

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar

  normalize_attribute :fullname, :avatar

  def self.admin_user_types
    [TYPE_SUPERADMIN, TYPE_FACULTY]
  end

  validates :email, presence: true, email: true
  validates :fullname, presence: true
  validates :admin_type, inclusion: { in: admin_user_types }, allow_nil: true

  after_create :link_to_user

  def link_to_user
    user = User.with_email(email)
    user = User.create!(email: email) if user.blank?
    update!(user: user)
  end

  def display_name
    email
  end

  def superadmin?
    admin_type == TYPE_SUPERADMIN
  end
end
