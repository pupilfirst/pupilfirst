class State < ActiveRecord::Base
  validates :name, presence: true

  has_many :colleges
  has_many :replacement_universities
  has_many :batch_applicants, through: :colleges
  has_many :batch_applications, through: :batch_applicants
end
