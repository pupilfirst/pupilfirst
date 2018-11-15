class AddResubmittableToTarget < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :resubmittable, :boolean, default: true
  end
end
