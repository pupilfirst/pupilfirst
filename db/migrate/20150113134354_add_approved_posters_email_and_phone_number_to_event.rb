class AddApprovedPostersEmailAndPhoneNumberToEvent < ActiveRecord::Migration
  def change
    add_column :events, :approved, :boolean
    add_column :events, :posters_email, :string
    add_column :events, :posters_phone_number, :integer
  end
end
