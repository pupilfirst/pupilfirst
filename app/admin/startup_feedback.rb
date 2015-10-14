ActiveAdmin.register StartupFeedback do
  menu parent: 'Startups', label: 'Feedback'
  permit_params :feedback, :reference_url, :startup_id, :send_email, :faculty_id, :activity_type

  preserve_default_filters!
  filter :startup_product_name, as: :select, collection: proc { Startup.all.pluck(:product_name).uniq }

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
          span startup.product_name

          if startup.name.present?
            span class: 'wrap-with-paranthesis' do
              startup.name
            end
          end
        end
      end
    end

    column :feedback do |startup_feedback|
      pre class: 'max-width-pre' do
        startup_feedback.feedback
      end
    end

    column :reference_url do |startup_feedback|
      if startup_feedback.reference_url.present?
        link_to 'Link', startup_feedback.reference_url
      end
    end

    column :faculty
    column :created_at

    column :sent_at do |startup_feedback|
      if startup_feedback.sent_at.present?
        startup_feedback.sent_at
      else
        link_to(
          'Email Now!',
          email_feedback_admin_startup_feedback_path(startup_feedback),
          method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founders?' }
        )
      end
    end

    actions
  end

  show do
    attributes_table do
      row :product do |startup_feedback|
        startup = startup_feedback.startup

        if startup
          a href: admin_startup_path(startup) do
            span startup.product_name

            if startup.name.present?
              span class: 'wrap-with-paranthesis' do
                startup.name
              end
            end
          end
        end
      end

      row :feedback do |startup_feedback|
        pre class: 'max-width-pre' do
          startup_feedback.feedback
        end
      end
      row :activity_type

      row :reference_url
      row :faculty

      row :sent_at do |startup_feedback|
        if startup_feedback.sent_at.present?
          startup_feedback.sent_at
        else
          link_to(
            'Email Now!',
            email_feedback_admin_startup_feedback_path(startup_feedback),
            method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founders?' }
          )
        end
      end
    end
  end

  form partial: 'admin/startup_feedback/form'

  member_action :email_feedback, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    startup_feedback.update(sent_at: Time.now)
    StartupMailer.feedback_as_email(startup_feedback).deliver_later
    flash[:alert] = 'Your feedback has been sent to the startup founders!'
    redirect_to action: :index
  end

  action_item :email_feedback, only: :show, if: proc { startup_feedback.sent_at.blank? } do
    link_to(
      'Email Now!',
      email_feedback_admin_startup_feedback_path(startup_feedback),
      method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founders?' }
    )
  end
end
