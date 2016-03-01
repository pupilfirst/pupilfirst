ActiveAdmin.register Resource do
  menu parent: 'Startups'

  permit_params :title, :description, :file, :thumbnail, :share_status, :batch_id, :startup_id, :tag_list

  preserve_default_filters!

  filter :startup,
    collection: Startup.batched,
    label: 'Product',
    member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : 's'}" }

  filter :share_status,
    collection: Resource.valid_share_statuses

  index do
    selectable_column

    column :share_status do |resource|
      if resource.share_status.present?
        t("resource.share_status.#{resource.share_status}")
      end
    end

    column 'Shared with' do |resource|
      if resource.for_approved?
        if resource.startup.present?
          link_to resource.startup.product_name, admin_startup_path(resource.startup)
        elsif resource.batch.present?
          link_to resource.batch.to_label, admin_batch_path(resource.batch)
        else
          'All batches'
        end
      else
        'Public'
      end
    end

    column :title
    column :downloads
    column :tag_list
    actions
  end

  show do
    attributes_table do
      row :share_status do |resource|
        if resource.share_status.present?
          t("resource.share_status.#{resource.share_status}")
        end
      end

      row 'Shared with' do |resource|
        if resource.for_approved?
          if resource.startup.present?
            link_to resource.startup.product_name, admin_startup_path(resource.startup)
          elsif resource.batch.present?
            link_to resource.batch.to_label, admin_batch_path(resource.batch)
          else
            'All batches'
          end
        else
          'Public'
        end
      end

      row :title
      row :downloads

      row :tags do |resource|
        resource.tags.map(&:name).join ', '
      end

      row :description

      row :thumbnail do |resource|
        if resource.thumbnail.present?
          img src: resource.thumbnail_url
        else
          image_tag 'resources/thumbnail_default.png'
        end
      end

      row :content_type
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Resource details' do
      f.input :share_status,
        as: :select,
        collection: Resource.valid_share_statuses,
        member_label: proc { |share_status| t("resource.share_status.#{share_status}") }

      f.input :batch, label: 'Shared with Batch', placeholder: 'Leave this unselected to share with all batches.'
      f.input :startup, label: 'Shared with Startup'
      f.input :file, as: :file
      f.input :thumbnail, as: :file
      f.input :title
      f.input :description
      f.input :tag_list, input_html: { value: f.object.tag_list.join(','), 'data-tags' => Resource.tag_counts_on(:tags).pluck(:name).to_json }
    end

    f.actions
  end

  action_item :view_resource, only: :show do
    link_to('View Resource', "/resources/#{resource.slug}", target: '_blank')
  end
end
