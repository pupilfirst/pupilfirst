class ApplicationStage < ActiveRecord::Base
  has_many :batch_applications
  has_many :batches

  # Returns next stage using number.
  def next
    ApplicationStage.find_by number: (number + 1)
  end
end
