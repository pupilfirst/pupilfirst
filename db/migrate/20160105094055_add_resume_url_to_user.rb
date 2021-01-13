class AddResumeUrlToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :resume_url, :string
  end
end
