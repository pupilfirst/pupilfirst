class Batch < ActiveRecord::Base
  has_many :startups
  scope :current, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now).first }
  validates :name, presence: true, uniqueness: true
  validates_presence_of :start_date, :end_date
end
