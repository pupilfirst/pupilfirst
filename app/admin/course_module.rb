ActiveAdmin.register CourseModule do
  # accounting for use of friendly_id without finders
  controller do
    include DisableIntercom

    def find_resource
      scoped_collection.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      scoped_collection.find(params[:id])
    end
  end

  menu parent: 'SixWays'
  filter :name
  filter :module_number

  permit_params :name, :module_number, :publish_at,
    module_chapters_attributes: %i[id chapter_number name serialized_links _destroy]

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :module_number
      f.input :publish_at, as: :datepicker

      f.inputs 'Chapters' do
        f.has_many :module_chapters, heading: false, allow_destroy: true, new_record: 'Add Chapter' do |o|
          o.input :name
          o.input :chapter_number
          o.input :serialized_links, as: :text, hint: 'Add as JSON array. Eg: [{"title": "Title", "url" : "sv.co"}, {"title": "Title", "url" : "sv.co"}]', input_html: { rows: 10 }
        end
      end
    end

    f.actions
  end

  index do
    selectable_column

    column :module_number
    column :name
    column :publish_at
    column :chapters do |course_module|
      course_module.module_chapters.pluck(:name).join(', ')
    end

    actions
  end

  show do
    attributes_table do
      row :module_number
      row :name
      row :publish_at
      row :chapters do |course_module|
        course_module.module_chapters.pluck(:name).join(', ')
      end
    end
  end
end
