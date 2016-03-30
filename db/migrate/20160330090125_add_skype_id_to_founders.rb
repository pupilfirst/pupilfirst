class AddSkypeIdToFounders < ActiveRecord::Migration
  def change
    add_column :founders, :skype_id, :string
  end
end
