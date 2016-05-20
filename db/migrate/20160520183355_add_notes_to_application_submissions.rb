class AddNotesToApplicationSubmissions < ActiveRecord::Migration
  def change
    add_column :application_submissions, :notes, :text
  end
end
