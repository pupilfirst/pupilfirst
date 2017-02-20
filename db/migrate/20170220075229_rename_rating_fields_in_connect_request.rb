class RenameRatingFieldsInConnectRequest < ActiveRecord::Migration[5.0]
  def change
    rename_column :connect_requests, :rating_of_faculty, :rating_for_faculty
    rename_column :connect_requests, :rating_of_team, :rating_for_team
  end
end
