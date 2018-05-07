class State < ApplicationRecord
  validates :name, presence: true

  has_many :colleges, dependent: :restrict_with_error
  has_many :universities, dependent: :restrict_with_error

  def self.names_for_mooc_student
    ['Outside India'] + all.pluck(:name).sort
  end
end
