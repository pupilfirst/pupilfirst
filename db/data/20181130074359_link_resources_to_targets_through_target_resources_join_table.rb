class LinkResourcesToTargetsThroughTargetResourcesJoinTable < ActiveRecord::Migration[5.2]
  def up
    Resource.joins(:target).each do |resource|
      TargetResource.create!(resource_id: resource.id, target_id: resource.target_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
