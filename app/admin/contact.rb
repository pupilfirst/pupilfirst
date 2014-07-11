ActiveAdmin.register Contact do
  remove_filter :contacts_categories
  remove_filter :versions

  preserve_default_filters!
  filter :categories, collection: Category.contact_category

  controller do
    newrelic_ignore
  end

  index do
    selectable_column
    column :name
    column :mobile
    column :email
    column :designation
    column :company

    # Show categories as comma-separated list.
    column :categories, sortable: false do |c|
      c.categories.map(&:name).join ', '
    end

    column :updated_at
    actions
  end

  form do |f|
    f.inputs

    f.inputs do
      f.input :categories, collection: Category.contact_category, as: :check_boxes
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :mobile
      row :email
      row :designation
      row :company

      row :categories do |contact|
        contact.categories.map(&:name).join ', '
      end

      row :created_at
      row :updated_at
    end
  end

  permit_params :name, :mobile, :email, :designation, :company, category_ids: []
end
