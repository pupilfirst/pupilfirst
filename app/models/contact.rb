# Stores contact details of important people, to be selectively shared with the userbase.
class Contact < ActiveRecord::Base
  has_paper_trail

  has_and_belongs_to_many :categories
  accepts_nested_attributes_for :categories

  # Validate e-mail address
  validates_uniqueness_of :email, allow_nil: true, allow_blank: true

  # Validate the mobile number
  validates_presence_of :mobile, unique: true
  validates_plausible_phone :mobile

  # Store mobile number in a standardized form.
  phony_normalize :mobile, default_country_code: 'IN'
end
