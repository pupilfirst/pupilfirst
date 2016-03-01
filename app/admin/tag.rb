ActiveAdmin.register ActsAsTaggableOn::Tagging, as: 'Tags' do
  actions :index

  index do
    selectable_column

    column :tag do |tagging|
      tagging.tag.name
    end

    column :taggable
    column :taggable_type
    column :created_at

    actions
  end
end
