ActiveAdmin.register Resource do
  permit_params :title, :description, :file, :video_embed, :link, :archived, :public, :school_id, tag_list: [], target_ids: []

  controller do
    include DisableIntercom

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Resource.tag_counts_on(:tags).pluck(:name).sort }

  filter :title
  filter :description
  filter :archived
  filter :school

  batch_action :tag, form: proc { { tag: Resource.tag_counts_on(:tags).pluck(:name) } } do |ids, inputs|
    Resource.where(id: ids).each do |resource|
      resource.tag_list.add inputs[:tag]
      resource.save!
    end

    redirect_to collection_path, alert: 'Tag added!'
  end

  index do
    selectable_column

    column :public
    column :school
    column :title
    column :downloads

    column :tags do |resource|
      linked_tags(resource.tags, separator: ' | ')
    end

    actions
  end

  show do
    attributes_table do
      row :title
      row :downloads

      row :file do |resource|
        if resource.file.attached?
          link_to resource.file.filename, resource.file
        end
      end

      row :tags do |resource|
        linked_tags(resource.tags)
      end

      row :description
      row :video_embed do |resource|
        resource.video_embed&.html_safe
      end

      row :link do |resource|
        resource.link&.html_safe
      end

      row :created_at
      row :updated_at

      row :targets do |resource|
        none_one_or_many(self, resource.targets) do |target|
          link_to target.title, admin_target_path(target)
        end
      end

      row :archived
      row :public
      row :school
    end
  end

  form do |f|
    div id: 'admin-resource__edit'

    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Resource details' do
      f.input :file, as: :file
      f.input :title
      f.input :description
      f.input :video_embed
      f.input :link

      f.input :tag_list,
        as: :select,
        collection: Resource.tag_counts_on(:tags).pluck(:name),
        multiple: true

      f.input :targets, collection: f.object.targets
      f.input :archived
      f.input :school
      f.input :public
    end

    f.actions
  end

  action_item :view_resource, only: :show do
    link_to('View Resource', "/resources/#{resource.slug}", target: '_blank', rel: 'noopener')
  end
end
