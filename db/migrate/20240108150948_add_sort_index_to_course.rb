class AddSortIndexToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :sort_index, :integer, default: 0
  end
end
