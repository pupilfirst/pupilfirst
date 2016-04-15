class AddSlackFieldsToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :slack_username, :string
    add_column :faculty, :slack_user_id, :string
  end
end
