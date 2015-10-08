ActiveAdmin.register Resource do
  menu parent: 'Startups'

  permit_params :title, :description, :file, :thumbnail, :share_status, :shared_with_batch

  preserve_default_filters!

  filter :startup,
    collection: Startup.batched,
    label: 'Product',
    member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : 's'}" }

  filter :share_status,
    collection: Resource.valid_share_statuses

  index do
    selectable_column

    column :share_status

    column :shared_with_batch do |resource|
      if resource.shared_with_batch.present?
        resource.shared_with_batch
      else
        'All batches'
      end
    end

    column :title
    actions
  end

  show do
    attributes_table do
      row :share_status

      row :shared_with_batch do |resource|
        if resource.shared_with_batch.present?
          resource.shared_with_batch
        else
          'All batches'
        end
      end

      row :title
      row :description

      row :thumbnail do |resource|
        img src: resource.thumbnail_url
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Resource details' do
      f.input :share_status,
        as: :select,
        collection: Resource.valid_share_statuses,
        member_label: proc { |share_status| share_status.capitalize }
      f.input :shared_with_batch, placeholder: 'Leave this blank to share with all batches.'
      f.input :file, as: :file
      f.input :thumbnail, as: :file
      f.input :title
      f.input :description
    end

    f.actions
  end
end
