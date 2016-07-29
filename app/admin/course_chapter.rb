ActiveAdmin.register CourseModule do
  include DisableIntercom

  menu parent: 'StartInCollege'
  filter :name
  filter :chapter_number

  permit_params :name, :chapter_number, chapter_sections_attributes: [:id, :section_number, :name, :_destroy]

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :chapter_number

      f.inputs 'Sections' do
        f.has_many :chapter_sections, heading: false, allow_destroy: true, new_record: 'Add Section' do |o|
          o.input :name
          o.input :section_number
        end
      end
    end

    f.actions
  end

  index do
    selectable_column

    column :chapter_number
    column :name
    column :sections do |chapter|
      chapter.chapter_sections.pluck(:name).join(', ')
    end

    actions
  end

  show do
    attributes_table do
      row :chapter_number
      row :name
      row :sections do |chapter|
        chapter.chapter_sections.pluck(:name).join(', ')
      end
    end
  end
end
