class ChangeDefaultPreferencesForUser < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :preferences, from: {}, to: { daily_digest: true }
  end
end
