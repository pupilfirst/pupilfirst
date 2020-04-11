class CreateBounceReports < ActiveRecord::Migration[6.0]
  class User < ActiveRecord::Base
  end

  class BounceReport < ActiveRecord::Base
  end

  def up
    enable_extension 'citext'
    create_table :bounce_reports do |t|
      t.citext :email, null: false
      t.string :bounce_type, null: false

      t.timestamps
    end

    add_index :bounce_reports, :email, unique: true

    BounceReport.reset_column_information

    User.where.not(email_bounced_at: nil).find_each do |user|
      BounceReport.where(email: user.email).first_or_create!(bounce_type: user.email_bounce_type || 'HardBounce')
    end
  end

  def down
    drop_table :bounce_reports
  end
end
