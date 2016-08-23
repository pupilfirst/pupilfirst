class SetApplicantReferenceDefaultToOther < ActiveRecord::Migration
  def change
    change_column_default :batch_applicants, :reference, 'Other'
  end
end
