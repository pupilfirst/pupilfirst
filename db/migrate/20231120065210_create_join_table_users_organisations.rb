class CreateJoinTableUsersOrganisations < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :organisations do |t|
      t.index %i[user_id organisation_id]
      t.index %i[organisation_id user_id]
    end

    RateLimitValidator.migration_running = true

    User.find_each do |user|
      org_id = user.organisation_id
      next unless org_id

      OrganisationsUser.create!(user_id: user.id, organisation_id: org_id)
    end

    remove_column :users, :organisation_id

    RateLimitValidator.migration_running = false
  end

  def down
    add_column :users, :organisation_id, :bigint
    RateLimitValidator.migration_running = true
    User.all.each do |user|
      user_org = OrganisationsUser.find(user_id: user.id)
      next unless user_org

      user.update!(organisation_id: user_org.organisation_id)
    end
    RateLimitValidator.migration_running = false
    drop_join_table :users, :organisations
  end
end
