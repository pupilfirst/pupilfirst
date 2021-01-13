class SetApplicantReferenceDefaultToOther < ActiveRecord::Migration[4.2]
  def change
    change_column_default :batch_applicants, :reference, 'Other'
  end
end
