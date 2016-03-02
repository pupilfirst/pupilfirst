ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tags' do
  actions :all, except: [:new, :create]

  menu parent: 'Taggings'

  config.sort_order = 'taggings_count_desc'

  permit_params :name

  index do
    selectable_column

    column :name
    column :taggings_count

    actions
  end

  show do |tag|
    attributes_table do
      row :id
      row :name
      row :taggings_count
    end

    panel 'Taggings' do
      table_for tag.taggings do
        column :taggable
        column :taggable_type
        column :created_at
      end
    end
  end
end
