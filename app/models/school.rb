class School < ApplicationRecord
  validates :name, presence: true

  has_many :levels, dependent: :restrict_with_error

  def short_name
    name[0..2].upcase.strip
  end

  def facebook_share_disabled?
    name.include? 'Apple'
  end
end
