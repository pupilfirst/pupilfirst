class RemoveDescriptionFromEvaluationCriterion < ActiveRecord::Migration[6.0]
  def change
    remove_column :evaluation_criteria, :description, :string
  end
end
