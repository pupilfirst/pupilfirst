class AddTimestampsForUsers < ActiveRecord::Migration[5.2]
  def up
    User.includes(:school_admin, :founders, :faculty).all.each do |user|
      time = user.school_admin&.created_at || user.faculty&.created_at || user.founders.first&.created_at
      user.created_at = time if user.created_at.nil?
      user.updated_at = time if user.updated_at.nil?
      user.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
