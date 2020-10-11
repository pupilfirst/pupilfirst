class AddEditReasonToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :edit_reason, :string
  end
end
