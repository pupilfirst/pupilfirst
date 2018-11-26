class RemoveUnusedTargetRoles < ActiveRecord::Migration[5.2]
  def up
    Target.where.not(role: Target::ROLE_FOUNDER).update_all(role: Target::ROLE_TEAM)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
