class AddLocationToUniversities < ActiveRecord::Migration[4.2]
  def change
    add_column :universities, :location, :string
  end
end
