class University < ActiveRecord::Base
  has_many :users, dependent: :restrict_with_error

  validates_uniqueness_of :name, presence: true
  validates_presence_of :location

  def to_label
    name + (location.present? ? " [#{location}]" : '')
  end
end
