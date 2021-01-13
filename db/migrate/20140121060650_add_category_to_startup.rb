class AddCategoryToStartup < ActiveRecord::Migration[4.2]
  def change
    add_reference :startups, :category, index: true
  end
end
