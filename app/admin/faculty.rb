ActiveAdmin.register Faculty do
  permit_params :name, :title, :key_skills, :linkedin_url, :category, :image, :sort_index, :self_service,
    :current_commitment, :notify_for_submission, :about, :commitment, :compensation, :slack_username, :public, :connect_link

  actions :index, :show

  controller do
    include DisableIntercom

    def find_resource
      scoped_collection.find(params[:id])
    end
  end

  filter :category, as: :select, collection: -> { Faculty.valid_categories }
  filter :name
  filter :public
  filter :user_email, as: :string
  filter :title
  filter :key_skills
  filter :linkedin_url

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
      row :linkedin_url
      row :about
      row :key_skills
      row :category

      row :image do
        if faculty.image.attached?
          link_to(faculty.image.filename, url_for(faculty.image))
        end
      end

      row :sort_index
      row :public
      row :self_service
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

  form do |f|
    div id: 'admin-faculty__form'

    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Faculty Details' do
      f.input :category, as: :select, collection: Faculty.valid_categories
      f.input :name
      f.input :title
      f.input :about
      f.input :image, as: :file
      f.input :key_skills
      f.input :linkedin_url
      f.input :sort_index
      f.input :public
      f.input :notify_for_submission
      f.input :self_service
      f.input :commitment, as: :select, collection: commitment_options, label_method: :first, value_method: :last
      f.input :current_commitment
      f.input :compensation, as: :select, collection: Faculty.valid_compensation_values
      f.input :slack_username
      f.input :connect_link
    end

    f.actions
  end
end
