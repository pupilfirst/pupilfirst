class CreateStartups < ActiveRecord::Migration
  def change
    create_table :startups do |t|
      t.string :name
      t.string :logo
      t.string :pitch
      t.string :website
      t.string :about
      t.string :tags, array: true, default: []
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
