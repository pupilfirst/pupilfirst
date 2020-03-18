class AddPaymentTables < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_plans do |t|
      t.string :name, null: false
      t.text :description
      t.references :course, null: false, foreign_key: true
      t.boolean :showcase, null: false
      t.references :plan, polymorphic: true, null: false
      t.timestamps
    end

    create_table :free_plans do |t|
      t.integer :duration, null: false
      t.timestamps
    end

    create_table :subscription_plans do |t|
      t.integer :amount, null: false
      t.integer :interval_count, null: false
      t.string :interval, null: false
      t.timestamps
    end

    create_table :one_time_purchase_plans do |t|
      t.integer :amount, null: false
      t.integer :duration, null: false
      t.timestamps
    end

    create_table :billing_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    create_table :billing_beneficiary do |t|
      t.references :founder, null: false, foreign_key: true
      t.references :billing_account, null: false, foreign_key: true
      t.timestamps
    end

    create_table :billing_plans do |t|
      t.references :payment_plan, null: false, foreign_key: true
      t.references :billing_account, null: false, foreign_key: true
      t.timestamps
    end

    create_table :payments do |t|
      t.references :billing_plan, null: false, foreign_key: true
      t.integer :amount, null: false
      t.timestamps
    end

    create_table :coupons do |t|
      t.references :course, null: false, foreign_key: true
      t.text :description
      t.string :prefix, null: false
      t.jsonb :suffixes, null: false
      t.integer :discount, null: false
      t.integer :limit, null: false
      t.timestamps
    end

    create_table :coupon_usages do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :billing_plan, null: false, foreign_key: true
      t.string :suffix
      t.timestamps
    end
  end
end
