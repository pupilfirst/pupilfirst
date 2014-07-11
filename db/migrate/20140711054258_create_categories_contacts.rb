class CreateCategoriesContacts < ActiveRecord::Migration
  def change
    create_table :categories_contacts, id: false do |t|
      t.belongs_to :category
      t.belongs_to :contact
    end
  end
end
