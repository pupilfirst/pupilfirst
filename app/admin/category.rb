ActiveAdmin.register Category do
  remove_filter :categories_startups
  remove_filter :categories_users

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  controller do
    newrelic_ignore
  end
  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :category_type, collection: Category::TYPES, prompt: 'Choose a type'
    end
    f.actions
  end
  permit_params :name, :category_type
end
