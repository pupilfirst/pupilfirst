class AddNotesToBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applicants, :notes, :text
  end
end
