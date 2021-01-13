class AddNotesToApplicationSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :application_submissions, :notes, :text
  end
end
