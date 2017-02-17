ActiveAdmin.register TargetGroup do
  include DisableIntercom
  menu parent: 'Targets'

  permit_params :name, :description, :program_week_id, :sort_index, :level_id, :milestone

  controller do
    def scoped_collection
      super.includes :program_week, :level
    end
  end

  index do
    selectable_column

    column :program_week
    column :level
    column :milestone
    column :sort_index
    column :name
    column :description

    actions
  end
end
