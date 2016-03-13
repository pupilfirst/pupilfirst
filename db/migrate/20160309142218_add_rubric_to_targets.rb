class AddRubricToTargets < ActiveRecord::Migration
  def change
    add_column :targets, :rubric, :string
  end
end
