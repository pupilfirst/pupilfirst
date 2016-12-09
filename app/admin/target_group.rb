ActiveAdmin.register TargetGroup do
  include DisableIntercom
  menu parent: 'Targets'

  permit_params :name, :description, :program_week_id, :sort_index

  controller do
    def scoped_collection
      super.includes :program_week
    end
  end

  index do
    selectable_column

    column :program_week
    column :sort_index
    column :name
    column :description

    actions
  end
end
