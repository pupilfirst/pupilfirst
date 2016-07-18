ActiveAdmin.register CourseChapter do
  menu parent: 'StartInCollege'
  filter :name
  filter :chapter_number

  permit_params :name, :chapter_number, :sections_count

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :chapter_number
      f.input :sections_count
    end

    f.actions
  end

  index do
    selectable_column

    column :chapter_number
    column :name
    column :sections_count

    actions
  end
end
