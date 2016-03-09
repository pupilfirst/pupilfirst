ActiveAdmin.register ActsAsTaggableOn::Tagging, as: 'Tagging' do
  actions :index, :destroy

  index do
    selectable_column

    column :tag do |tagging|
      link_to tagging.tag.name, admin_tag_path(tagging.tag)
    end

    column :taggable
    column :taggable_type
    column :created_at

    actions
  end
end
