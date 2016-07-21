class AddNotesToBatchApplicant < ActiveRecord::Migration
  def change
    add_column :batch_applicants, :notes, :text
  end
end
