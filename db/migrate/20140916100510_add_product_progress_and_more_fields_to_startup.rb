class AddProductProgressAndMoreFieldsToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :product_progress, :string
    add_column :startups, :presentation_link, :string
    add_column :startups, :revenue_generated, :integer
  end
end
