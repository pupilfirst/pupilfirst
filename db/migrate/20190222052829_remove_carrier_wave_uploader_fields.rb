class RemoveCarrierWaveUploaderFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :founders, :avatar, :string
    remove_column :timeline_event_files, :file, :string
    remove_column :faculty, :image, :string
    remove_column :resources, :file, :string
  end
end
