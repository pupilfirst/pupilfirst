class AddProcessingUrlToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :processing_url, :string
    add_column :courses, :highlights, :jsonb, default: []
  end
end
