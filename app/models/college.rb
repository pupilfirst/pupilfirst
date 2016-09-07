class College < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :state
  belongs_to :replacement_university
end
