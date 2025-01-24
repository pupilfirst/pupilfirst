# frozen_string_literal: true

class AdminUser < ApplicationRecord
  acts_as_copy_target

  normalize_attribute :fullname

  validates :fullname, presence: true

  def display_name
    fullname
  end
end
