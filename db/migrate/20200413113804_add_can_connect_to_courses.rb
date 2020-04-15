class AddCanConnectToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :can_connect, :boolean, default: true
  end
end
