class AddConfigurationToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :configuration, :jsonb, default: {}, null: false
  end
end
