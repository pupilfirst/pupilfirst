ActiveAdmin.register Faculty do
  permit_params :name, :email, :title, :key_skills, :linkedin_url, :category, :image, :sort_index, :self_service, :current_commitment

  config.sort_order = 'sort_index_asc'

  filter :category, as: :select, collection: Faculty.valid_categories
  filter :name
  filter :email
  filter :title
  filter :key_skills
  filter :linkedin_url

  index do
    selectable_column
    column :category
    column :name
    column :email
    column :title
    column :sort_index
    actions
  end

  form do |f|
    f.inputs 'Faculty Details' do
      f.input :category, as: :select, collection: Faculty.valid_categories
      f.input :name
      f.input :email
      f.input :title
      f.input :image, as: :file
      f.input :key_skills
      f.input :linkedin_url
      f.input :sort_index
      f.input :self_service
      f.input :current_commitment
    end

    f.actions
  end
end
