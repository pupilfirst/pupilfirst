class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :batch_application, index: true, foreign_key: true
      t.string :instamojo_payment_request_id
      t.string :instamojo_payment_request_status
      t.string :instamojo_payment_id
      t.string :instamojo_payment_status
      t.decimal :amount, precision: 9, scale: 2
      t.decimal :fees, precision: 9, scale: 2
      t.string :short_url
      t.string :long_url

      t.timestamps null: false
    end
  end
end
