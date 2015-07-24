ActiveAdmin.register Category do
  filter :name
  filter :category_type, as: :select, collection: proc { Category::TYPES }

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
        collection: Category::TYPES,
        prompt: 'Choose a type'
    end
    f.actions
  end

  permit_params :name, :category_type
end
