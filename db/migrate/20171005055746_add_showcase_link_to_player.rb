class AddShowcaseLinkToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :showcase_link, :string
  end
end
