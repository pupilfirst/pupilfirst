class CreateBounceReports < ActiveRecord::Migration[6.0]
  class User < ActiveRecord::Base
  end

  class BounceReport < ActiveRecord::Base
  end

  def up
    create_table :bounce_reports do |t|
      t.string :email, index: true
      t.string :bounce_type

      t.timestamps
    end

    BounceReport.reset_column_information

    User.all.each do |user|
      next if user.email_bounced_at.blank?

      BounceReport.where(email: user.email).first_or_create!(bounce_type: user.email_bounce_type)
    end
  end

  def down
    drop_table :bounce_reports
  end
end
