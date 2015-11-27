class Batch < ActiveRecord::Base
  has_many :startups

  validates :name, presence: true, uniqueness: true
  validates_presence_of :start_date, :end_date
end
