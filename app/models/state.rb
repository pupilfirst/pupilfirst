class State < ApplicationRecord
  validates :name, presence: true

  has_many :colleges
  has_many :universities

  def self.names_for_mooc_student
    ['Outside India'] + all.pluck(:name).sort
  end
end
