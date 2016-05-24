class ApplicationStage < ActiveRecord::Base
  has_many :batch_applications
  has_many :batches

  validates :name, presence: true
  validates :number, presence: true
  validates :days_before_batch, presence: true

  # Returns next stage using number.
  def next
    ApplicationStage.find_by number: (number + 1)
  end
end
