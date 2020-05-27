ActiveAdmin.register Startup do
  permit_params :name, :created_at, :updated_at, :slug,
    :level_id, founder_ids: [], tag_list: []

  filter :name, as: :string
  filter :level_course_id, as: :select, label: 'Course', collection: -> { Course.all }
  filter :level, collection: -> { Level.all.order(number: :asc) }

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Startup.tag_counts_on(:tags).pluck(:name).sort }

  filter :created_at

  scope :admitted, default: true
  scope :inactive
  scope :all

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  collection_action :search_startup do
    render json: Startups::Select2SearchService.search_for_startup(params[:q])
  end

  batch_action :tag, form: proc { { tag: Startup.tag_counts_on(:tags).pluck(:name) } } do |ids, inputs|
    Startup.where(id: ids).each do |startup|
      startup.tag_list.add inputs[:tag]
      startup.save!
    end

    redirect_to collection_path, alert: 'Tag added!'
  end

  index do
    selectable_column

    column :product do |startup|
      link_to startup.display_name, admin_startup_path(startup)
    end

    column :level

    actions do |startup|
      span do
        link_to 'View All Feedback',
          admin_startup_feedback_index_url('q[startup_id_eq]' => startup.id, commit: 'Filter'),
          class: 'member_link'
      end
    end
  end

  csv do
    column :name
    column(:level) { |startup| startup.level.number }
    column(:founders) { |startup| startup.founders.joins(:user).pluck(:name).join(',') }
  end

  action_item :view_feedback, only: :show do
    link_to(
      'View All Feedback',
      admin_startup_feedback_index_url('q[startup_id_eq]' => Startup.friendly.find(params[:id]).id, commit: 'Filter')
    )
  end

  member_action :get_all_startup_feedback do
    startup = Startup.friendly.find params[:id]
    feedback = startup.startup_feedback.order('updated_at desc')

    respond_to do |format|
      format.json do
        render json: { feedback: feedback, name: startup.name }
      end
    end
  end

  show title: :name do |startup|
    attributes_table do
      row :level
      row :faculty do
        div do
          if startup.faculty.present?
            startup.faculty.each do |faculty|
              span do
                link_to faculty.name, [:admin, faculty]
              end
            end
          end
        end
      end

      row :tags do
        linked_tags(startup.tags)
      end

      row :email

      row :founders do
        div do
          startup.founders.each do |founder|
            div do
              span do
                link_to founder.display_name, [:admin, founder]
              end
            end
          end
        end
      end
    end

    panel 'Technical details' do
      attributes_table_for startup do
        row :id
        row :created_at
        row :updated_at
      end
    end

    active_admin_comments
  end

  form partial: 'admin/startups/form'
end
