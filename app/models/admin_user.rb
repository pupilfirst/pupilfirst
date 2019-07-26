# frozen_string_literal: true

class AdminUser < ApplicationRecord
  normalize_attribute :fullname

  validates :fullname, presence: true

  def display_name
    fullname
  end
end
