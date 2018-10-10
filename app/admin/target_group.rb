ActiveAdmin.register TargetGroup do
  menu parent: 'Targets'

  permit_params :name, :description, :sort_index, :level_id, :milestone, :track_id

  filter :level
  filter :name, as: :string
  filter :description, as: :string
  filter :milestone
  filter :track
  filter :school, as: :select

  scope :all
  scope('No Track') { |scope| scope.where(track: nil) }

  controller do
    include DisableIntercom

    def scoped_collection
      super.includes({ level: :school }, :track)
    end
  end

  index do
    selectable_column

    column :level
    column :track
    column :milestone
    column :sort_index
    column :name

    actions
  end
end
