class ApplicationStage < ActiveRecord::Base
  has_many :batch_applications
  has_many :batches

  validates :name, presence: true
  validates :number, presence: true

  # Returns stage 1 (application process).
  def self.initial_stage
    find_by(number: 1)
  end

  # Returns next stage using number.
  def next
    ApplicationStage.find_by number: (number + 1)
  end

  def initial_stage?
    number == 1
  end
end
