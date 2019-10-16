class SetTitleForAllUsers < ActiveRecord::Migration[6.0]
  def up
    User.joins(:founders).where(title: nil).update_all(title: 'Student')
    User.joins(:faculty).where(title: nil).update_all(title: 'Coach')
    User.joins(:school_admin).where(title: nil).update_all(title: 'School Admin')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
