class AddAboutToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :about, :text
  end
end
