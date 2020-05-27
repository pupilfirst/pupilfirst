ActiveAdmin.register Faculty do
  actions :index, :show

  controller do
    def find_resource
      scoped_collection.find(params[:id])
    end
  end

  filter :category, as: :select, collection: -> { Faculty.valid_categories }
  filter :name
  filter :public
  filter :user_email, as: :string
  filter :title

  scope :all

  index do
    selectable_column

    column :category
    column :name
    column :email
    column :sort_index
    column :public
    column :connect_link

    actions
  end

  show do |faculty|
    attributes_table do
      row :name
      row :title
      row :email
      row :about
      row :category

      row :image do
        if faculty.image.attached?
          link_to(faculty.image.filename, url_for(faculty.image))
        end
      end

      row :sort_index
      row :public
      row :notify_for_submission
      row :slack_username
      row :connect_link

      row :startups do
        none_one_or_many(self, faculty.startups) do |startup|
          link_to startup.name, [:admin, startup]
        end
      end

      row :courses do
        none_one_or_many(self, faculty.courses) do |course|
          link_to course.name, [:admin, course]
        end
      end

      row :user
    end
  end
end
