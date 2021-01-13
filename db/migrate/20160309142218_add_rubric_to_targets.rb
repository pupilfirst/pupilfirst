class AddRubricToTargets < ActiveRecord::Migration[4.2]
  def change
    add_column :targets, :rubric, :string
  end
end
