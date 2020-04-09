class CreateCertificateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :certificates do |t|
      t.references :course, foreign_key: true, null: false
      t.string :qr_corner
      t.integer :name_offset_top
      t.boolean :active, default: false

      t.timestamps
    end

    create_table :issued_certificates do |t|
      t.references :certificate, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.string :name
      t.string :serial_number
    end

    add_index :issued_certificates, :serial_number, unique: true
  end
end
