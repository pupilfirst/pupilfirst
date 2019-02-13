class RemoveStaleFounderFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :founders, :invitation_token
    remove_column :founders, :invitation_created_at
    remove_column :founders, :invitation_sent_at
    remove_column :founders, :invitation_accepted_at
    remove_column :founders, :invited_by_id
    remove_column :founders, :invited_by_type
    remove_column :founders, :invitation_limit
    remove_column :founders, :born_on
    remove_column :founders, :college_course
    remove_column :founders, :semester
    remove_column :founders, :year_of_graduation
    remove_column :founders, :roll_number
    remove_column :founders, :backlog
    remove_column :founders, :parent_name
    remove_column :founders, :id_proof_type
    remove_column :founders, :id_proof_number
    remove_column :founders, :college_contact
    remove_column :founders, :invited_startup_id
    remove_column :founders, :screening_data
    remove_column :founders, :coder
    remove_column :founders, :reference
  end
end
