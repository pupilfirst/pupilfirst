# frozen_string_literal: true

class AdminUser < ApplicationRecord
  TYPE_SUPERADMIN = 'superadmin'
  TYPE_FACULTY = 'faculty'

  normalize_attribute :fullname

  def self.admin_user_types
    [TYPE_SUPERADMIN, TYPE_FACULTY]
  end

  validates :fullname, presence: true
  validates :admin_type, inclusion: { in: admin_user_types }, allow_nil: true

  def display_name
    fullname
  end

  def superadmin?
    admin_type == TYPE_SUPERADMIN
  end
end
