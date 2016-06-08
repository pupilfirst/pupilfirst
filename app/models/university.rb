class University < ActiveRecord::Base
  has_many :founders, dependent: :restrict_with_error

  validates_uniqueness_of :name, presence: true
  validates_presence_of :location

  def self.grouped_by_location
    all.each_with_object({}) do |university, grouped|
      grouped[university.location] ||= []
      grouped[university.location] << [university.id, university.name]
    end
  end
end
