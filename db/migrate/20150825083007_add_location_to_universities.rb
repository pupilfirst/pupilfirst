class AddLocationToUniversities < ActiveRecord::Migration
  def change
    add_column :universities, :location, :string
  end
end
