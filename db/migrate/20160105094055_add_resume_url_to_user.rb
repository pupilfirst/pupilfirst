class AddResumeUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :resume_url, :string
  end
end
