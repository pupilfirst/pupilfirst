class AddCategoryToStartup < ActiveRecord::Migration
  def change
    add_reference :startups, :category, index: true
  end
end
