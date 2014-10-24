class StartupLink < ActiveRecord::Base
  belongs_to :startup

  validates_length_of :name, maximum: 100
  validates_length_of :url, maximum: 255
  validates :url, url: true
  validates_length_of :description, maximum: 255, allow_nil: true
end
