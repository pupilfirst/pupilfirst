class RemoveCompanyIdFromMentors < ActiveRecord::Migration[4.2]
  def change
    remove_column :mentors, :company_id, :integer
  end
end
