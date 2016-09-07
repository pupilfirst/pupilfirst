class State < ActiveRecord::Base
  validates :name, presence: true

  has_many :colleges
  has_many :replacement_universities
end
