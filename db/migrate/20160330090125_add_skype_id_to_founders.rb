class AddSkypeIdToFounders < ActiveRecord::Migration[4.2]
  def change
    add_column :founders, :skype_id, :string
  end
end
