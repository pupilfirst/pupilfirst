ActiveAdmin.register TargetGroup do
  include DisableIntercom
  menu parent: 'Targets'

  permit_params :name, :description, :sort_index, :level_id, :milestone

  controller do
    def scoped_collection
      super.includes :level
    end
  end

  index do
    selectable_column

    column :level
    column :milestone
    column :sort_index
    column :name
    column :description

    actions
  end
end
