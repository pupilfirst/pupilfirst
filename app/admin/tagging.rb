ActiveAdmin.register ActsAsTaggableOn::Tagging, as: 'Tagging' do
  actions :index, :destroy

  menu false

  filter :taggable_type

  filter :tag, multiple: true, collection: proc {
    taggable_type = params.dig(:q, :taggable_type_eq)

    if taggable_type.present?
      ActsAsTaggableOn::Tag.joins(:taggings).where(taggings: { taggable_type: taggable_type }).distinct
    else
      ActsAsTaggableOn::Tag.all
    end
  }

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
