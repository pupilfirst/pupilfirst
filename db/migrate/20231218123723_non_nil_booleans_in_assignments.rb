class NonNilBooleansInAssignments < ActiveRecord::Migration[7.0]
  class Assignment < ApplicationRecord
  end

  def up
    Assignment.where(archived: nil).update_all(archived: false)

    change_column_default :assignments, :archived, from: nil, to: false
    change_column_null :assignments, :archived, false

    Assignment.where(milestone: nil).update_all(milestone: false)

    change_column_default :assignments, :milestone, from: nil, to: false
    change_column_null :assignments, :milestone, false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
