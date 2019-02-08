ActiveAdmin.register Startup do
  permit_params :product_name, :legal_registered_name,
    :created_at, :updated_at, :dropped_out,
    :slug, :level_id, founder_ids: [], tag_list: []

  filter :product_name, as: :string
  filter :level_course_id, as: :select, label: 'Course', collection: -> { Course.all }
  filter :level, collection: -> { Level.all.order(number: :asc) }

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Startup.tag_counts_on(:tags).pluck(:name).sort }

  filter :legal_registered_name
  filter :dropped_out
  filter :created_at

  scope :admitted, default: true
  scope :inactive_for_week
  scope :endangered
  scope :all

  controller do
    include DisableIntercom

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
    column :product_name
    column(:level) { |startup| startup.level.number }
    column(:founders) { |startup| startup.founders.pluck(:name).join ', ' }
    column(:women_cofounders) { |startup| startup.founders.where(gender: Founder::GENDER_FEMALE).count }
  end

  action_item :view_feedback, only: :show do
    link_to(
      'View All Feedback',
      admin_startup_feedback_index_url('q[startup_id_eq]' => Startup.friendly.find(params[:id]).id, commit: 'Filter')
    )
  end

  # TODO: rewrite as its only used for dropping out startups now
  member_action :custom_update, method: :put do
    startup = Startup.friendly.find params[:id]
    startup.update!(permitted_params[:startup])

    case params[:email_to_send].to_sym
      when :dropped_out
        StartupMailer.startup_dropped_out(startup).deliver_later
      # TODO: Re-write a mail welcoming the startup back after a drop-out ?
    end

    redirect_to action: :show
  end

  member_action :get_all_startup_feedback do
    startup = Startup.friendly.find params[:id]
    feedback = startup.startup_feedback.order('updated_at desc')

    respond_to do |format|
      format.json do
        render json: { feedback: feedback, product_name: startup.product_name }
      end
    end
  end

  show title: :product_name do |startup|
    attributes_table do
      row :legal_registered_name
      row :dropped_out do
        div class: 'startup-status' do
          startup.dropped_out
        end

        div class: 'startup-status-buttons' do
          unless startup.approved?
            span do
              button_to(
                'Approve Startup',
                custom_update_admin_startup_path(startup: { dropped_out: false }, email_to_send: :approval),
                method: :put, data: { confirm: 'Are you sure you want to approve this startup?' }
              )
            end
          end
          unless startup.dropped_out?
            span do
              button_to(
                'Drop-out Startup',
                custom_update_admin_startup_path(startup: { dropped_out: true }, email_to_send: :dropped_out),
                method: :put, data: { confirm: 'Are you sure you want to drop out this startup?' }
              )
            end
          end
        end
      end

      row :level
      row :maximum_level
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

              span do
                " &mdash; #{link_to 'Karma++'.html_safe, new_admin_karma_point_path(karma_point: { founder_id: founder.id })}".html_safe
              end
            end
          end
        end
      end

      row :women_cofounders do
        startup.founders.where(gender: Founder::GENDER_FEMALE).count
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
