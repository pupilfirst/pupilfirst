class AddSortIndexToSchoolLink < ActiveRecord::Migration[6.1]
  def change
    add_column :school_links, :sort_index, :integer, default: 0, null: false
  end
end
