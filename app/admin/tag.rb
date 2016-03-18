ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do
  actions :all, except: [:new, :create]

  menu parent: 'Taggings'

  config.sort_order = 'taggings_count_desc'

  permit_params :name

  filter :taggings_taggable_type_eq,
    as: :select,
    collection: proc { ActsAsTaggableOn::Tagging.distinct.pluck(:taggable_type) },
    label: 'Taggable Type'
  filter :name

  # Need to apply distinct after filtering since taggable type filter (above) is a join query that can return duplicates
  # of a tag in its results.
  controller do
    def apply_filtering(chain)
      @search = chain.ransack clean_search_params params[:q]
      @search.result(distinct: true)
    end
  end

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
