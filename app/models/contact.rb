class Contact < ActiveRecord::Base
  has_paper_trail

  # Validate e-mail address
  validates_uniqueness_of :email, allow_nil: true, allow_blank: true

  # Validate the mobile number
  validates_presence_of :mobile, unique: true
  validates_plausible_phone :mobile

  # Store mobile number in a standardized form.
  phony_normalize :mobile, default_country_code: 'IN'
end
