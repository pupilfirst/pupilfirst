class ConvertAdminCommentResourceIdToInteger < ActiveRecord::Migration[5.1]
  def up
    # Create a temporary column and create a composite index for it.
    add_column :active_admin_comments, :resource_id_i, :integer
    add_index :active_admin_comments, [:resource_type, :resource_id_i]

    # Copy int-casted values of keys to new column.
    ActiveAdmin::Comment.update_all('resource_id_i=(resource_id::integer)')

    # Disallow nulls on new column.
    change_column_null :active_admin_comments, :resource_id_i, false

    # Now drop the old column and rename the new one.
    remove_column :active_admin_comments, :resource_id
    rename_column :active_admin_comments, :resource_id_i, :resource_id
  end

  def down
    # Create a temporary column and create a composite index for it.
    add_column :active_admin_comments, :resource_id_s, :string
    add_index :active_admin_comments, [:resource_type, :resource_id_s]

    # Copy int-casted values of keys to new column.
    ActiveAdmin::Comment.update_all('resource_id_s=resource_id')

    # Disallow nulls on new column.
    change_column_null :active_admin_comments, :resource_id_s, false

    # Now drop the old column and rename the new one.
    remove_column :active_admin_comments, :resource_id
    rename_column :active_admin_comments, :resource_id_s, :resource_id
  end
end
