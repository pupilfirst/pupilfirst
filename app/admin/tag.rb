ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tags' do
  actions :index, :show, :edit, :update

  menu parent: 'Taggings'

  config.sort_order = 'taggings_count_desc'

  permit_params :name

  index do
    selectable_column

    column :name
    column :taggings_count

    actions
  end
end
