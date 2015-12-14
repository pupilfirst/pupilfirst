class AddCurrentCommitmentToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :current_commitment, :string
  end
end
