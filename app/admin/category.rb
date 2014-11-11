ActiveAdmin.register Category do
  filter :name
  filter :category_type, as: :select, collection: Category::TYPES

  controller do
    newrelic_ignore
  end

  index do
    selectable_column

    column :name
    column :category_type

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :category_type,
        collection: current_admin_user.admin_type == AdminUser::TYPE_EDITOR ? Category.editor_categories : Category::TYPES,
        prompt: 'Choose a type'
    end
    f.actions
  end

  permit_params :name, :category_type
end
