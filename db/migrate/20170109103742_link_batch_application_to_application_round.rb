class LinkBatchApplicationToApplicationRound < ActiveRecord::Migration[5.0]
  def change
    remove_reference :batch_applications, :batch
    add_reference :batch_applications, :application_round, foreign_key: true
  end
end
