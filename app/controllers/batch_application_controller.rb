class BatchApplicationController < ApplicationController
  def index
    @skip_container = true
  end

  def apply
    @batch = Batch.find_by(name: params[:batch]) || Batch.find_by(batch_number: params[:batch])
    stage_number = @batch&.application_stage&.number
    raise_not_found if stage_number.blank?
    render "batch_application/stage-#{stage_number}"
  end
end
