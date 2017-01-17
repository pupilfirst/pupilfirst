class ApplicationStage < ApplicationRecord
  has_many :batch_applications, dependent: :restrict_with_error

  validates :name, presence: true
  validates :number, presence: true, uniqueness: true

  def display_name
    "##{number} #{name}"
  end

  # Returns next stage using number.
  def next
    ApplicationStage.find_by number: (number + 1)
  end

  def previous
    ApplicationStage.find_by number: (number - 1)
  end

  def initial_stage?
    number == 1
  end

  def self.initial_stage
    find_by(number: 1)
  end

  def self.coding_stage
    find_by(number: 3)
  end

  # TODO: testing_stage is two different stages now.
  def self.testing_stage
    find_by(number: 2)
  end

  def self.interview_stage
    find_by(number: 5)
  end

  def self.shortlist_stage
    find_by(number: 6)
  end

  def self.final_stage
    find_by(final_stage: true)
  end
end
