ActiveAdmin.register ActsAsTaggableOn::Tagging, as: 'Tagging' do
  actions :index, :destroy

  filter :taggable_type
  filter :taggable,
    if: proc { params.dig(:q, :taggable_type_eq).present? },
    collection: proc { Object.const_get(params.dig(:q, :taggable_type_eq)).joins(:taggings).distinct }
  filter :tag

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
