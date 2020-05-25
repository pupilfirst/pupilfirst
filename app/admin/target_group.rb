ActiveAdmin.register TargetGroup do
  menu parent: 'Targets'

  permit_params :name, :description, :sort_index, :level_id, :milestone

  filter :level
  filter :name, as: :string
  filter :description, as: :string
  filter :milestone
  filter :course, as: :select

  controller do
    def scoped_collection
      super.includes(level: :course)
    end
  end

  index do
    selectable_column

    column :level
    column :milestone
    column :sort_index
    column :name

    actions
  end
end
