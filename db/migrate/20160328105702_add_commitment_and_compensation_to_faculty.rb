class AddCommitmentAndCompensationToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :commitment, :string
    add_column :faculty, :compensation, :string
  end
end
