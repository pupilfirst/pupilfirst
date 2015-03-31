class RemoveCompanyIdFromMentors < ActiveRecord::Migration
  def change
    remove_column :mentors, :company_id, :integer
  end
end
