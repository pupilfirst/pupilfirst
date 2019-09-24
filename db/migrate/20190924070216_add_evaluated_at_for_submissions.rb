class AddEvaluatedAtForSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :evaluated_at, :datetime
  end
end
