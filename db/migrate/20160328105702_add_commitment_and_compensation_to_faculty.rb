class AddCommitmentAndCompensationToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :commitment, :string
    add_column :faculty, :compensation, :string
  end
end
