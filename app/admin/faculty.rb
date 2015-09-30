ActiveAdmin.register Faculty do
  permit_params :name, :title, :key_skills, :linkedin_url, :category, :available_for_connect, :availability, :image

  index do
    selectable_column
    column :category
    column :name
    column :title
    column :available_for_connect
    actions
  end

  form do |f|
    f.inputs 'Faculty Details' do
      f.input :category, as: :select, collection: Faculty.valid_categories
      f.input :name
      f.input :title
      f.input :image, as: :file
      f.input :key_skills
      f.input :linkedin_url
      f.input :available_for_connect
      f.input :availability
    end
    f.actions
  end
end
