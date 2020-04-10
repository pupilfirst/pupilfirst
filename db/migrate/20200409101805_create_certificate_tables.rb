class CreateCertificateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :certificates do |t|
      t.references :course, foreign_key: true, null: false
      t.string :qr_corner, null: false
      t.integer :qr_scale, null: false
      t.integer :name_offset_top, null: false
      t.integer :font_size, null: false
      t.integer :margin, null: false
      t.boolean :active, default: false, null: false

      t.timestamps
    end

    create_table :issued_certificates do |t|
      t.references :certificate, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.string :name, null: false
      t.citext :serial_number, null: false

      t.timestamps
    end

    add_index :issued_certificates, :serial_number, unique: true
  end
end
