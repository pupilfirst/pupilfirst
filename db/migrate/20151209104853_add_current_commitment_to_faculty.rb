class AddCurrentCommitmentToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :current_commitment, :string
  end
end
