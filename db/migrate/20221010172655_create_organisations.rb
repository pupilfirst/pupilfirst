class CreateOrganisations < ActiveRecord::Migration[6.1]
  def change
    create_table :organisations do |t|
      t.string :name

      t.timestamps
    end

    create_table :organisation_admin do |t|
      t.references :organisation, null: false, foreign_key: true
      t.citext :email, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_reference :users, :organisation, null: true, foreign_key: true
  end
end
