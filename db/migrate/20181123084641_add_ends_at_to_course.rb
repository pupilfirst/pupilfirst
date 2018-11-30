class AddEndsAtToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :ends_at, :datetime
  end
end
