ActiveAdmin.register Resource do
  include DisableIntercom

  permit_params :title, :description, :file, :thumbnail, :share_status, :batch_id, :startup_id, :video_embed, tag_list: []

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  filter :startup,
    collection: Startup.batched.order(:product_name),
    label: 'Product'

  filter :share_status,
    collection: Resource.valid_share_statuses

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Resource.tag_counts_on(:tags).pluck(:name).sort }

  filter :batch
  filter :title
  filter :description

  batch_action :tag, form: proc { { tag: Resource.tag_counts_on(:tags).pluck(:name) } } do |ids, inputs|
    Resource.where(id: ids).each do |resource|
      resource.tag_list.add inputs[:tag]
      resource.save!
    end

    redirect_to collection_path, alert: 'Tag added!'
  end

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
          link_to resource.batch.display_name, admin_batch_path(resource.batch)
        else
          'All batches'
        end
      else
        'Public'
      end
    end

    column :title
    column :downloads

    column :tags do |resource|
      linked_tags(resource.tags, separator: ' | ')
    end

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
            link_to resource.batch.display_name, admin_batch_path(resource.batch)
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
        linked_tags(resource.tags)
      end

      row :description
      row :video_embed do |resource|
        resource.video_embed&.html_safe
      end

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
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Resource details' do
      f.input :share_status,
        as: :select,
        collection: Resource.valid_share_statuses.map { |s| [t("resource.share_status.#{s}"), s] },
        include_blank: false

      f.input :batch, label: 'Shared with Batch', placeholder: 'Leave this unselected to share with all batches.'
      f.input :startup, label: 'Shared with Startup'
      f.input :file, as: :file
      f.input :thumbnail, as: :file
      f.input :title
      f.input :description
      f.input :video_embed

      f.input :tag_list,
        as: :select,
        collection: Resource.tag_counts_on(:tags).pluck(:name),
        multiple: true
    end

    f.actions
  end

  action_item :view_resource, only: :show do
    link_to('View Resource', "/resources/#{resource.slug}", target: '_blank')
  end
end
