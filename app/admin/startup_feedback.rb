ActiveAdmin.register StartupFeedback do
  actions :index, :show
  menu parent: 'Startups', label: 'Feedback'
  permit_params :feedback, :reference_url, :startup_id, :send_email, :faculty_id, :activity_type, :timeline_event_id

  filter :startup_name, as: :string
  filter :faculty_user_name, as: :string
  filter :created_at
  filter :sent_at
  filter :activity_type

  controller do
    def scoped_collection
      super.includes :startup, :faculty
    end
  end

  index title: 'Startup Feedback' do
    selectable_column
    column :product do |startup_feedback|
      startup = startup_feedback.startup

      if startup
        a href: admin_startup_path(startup) do
          span startup.name
        end
      end
    end

    column :feedback_length do |startup_feedback|
      startup_feedback.feedback.length
    end

    column :timeline_event
    column :faculty
    column :created_at
    column :sent_at

    actions
  end

  show do
    attributes_table do
      row :product do |startup_feedback|
        startup = startup_feedback.startup

        if startup
          a href: admin_startup_path(startup) do
            span startup.name
          end
        end
      end

      row :feedback do |startup_feedback|
        pre startup_feedback.feedback
      end

      row :activity_type
      row :timeline_event
      row :reference_url
      row :faculty
      row :sent_at
    end
  end
end
