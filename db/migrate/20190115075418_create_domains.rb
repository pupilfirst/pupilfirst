class CreateDomains < ActiveRecord::Migration[5.2]
  def change
    create_table :domains do |t|
      t.references :school, foreign_key: true, index: true
      t.string :fqdn

      t.timestamps
    end

    # Each fully qualified domain name should be linked to only one school.
    add_index :domains, :fqdn, unique: true
  end
end
