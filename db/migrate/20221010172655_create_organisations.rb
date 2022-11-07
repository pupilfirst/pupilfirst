class CreateOrganisations < ActiveRecord::Migration[6.1]
  def change
    create_table :organisations do |t|
      t.string :name
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    create_table :organisation_admins do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :users, :organisation, null: true, foreign_key: true
  end
end
