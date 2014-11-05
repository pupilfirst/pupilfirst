class StartupLink < ActiveRecord::Base
  belongs_to :startup

  validates_length_of :name, within: 1..100
  validates_length_of :url, within: 1..255
  validates :url, url: true
  validates_length_of :description, maximum: 255

  nilify_blanks
end
