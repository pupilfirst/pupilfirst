class CreateJoinTableUsersOrganisations < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :organisations do |t|
      t.index %i[user_id organisation_id]
      t.index %i[organisation_id user_id]
    end

    RateLimitValidator.migration_running = true

    Organisation.all.each do |organisation|
      organisation.users.each do |user|
        user.organisations << organisation
        user.save
      end
    end

    remove_column :users, :organisation_id

    RateLimitValidator.migration_running = false
  end

  def down
    add_column :users, :organisation_id, :bigint
    RateLimitValidator.migration_running = true
    User.all.each do |user|
      user.organisation = user.organisations.first
      user.save
    end
    RateLimitValidator.migration_running = false
    drop_join_table :users, :organisations
  end
end
