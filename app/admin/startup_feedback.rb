ActiveAdmin.register StartupFeedback do
  menu parent: 'Startups', label: 'Feedback'
  permit_params :feedback, :reference_url, :startup_id, :send_email, :faculty_id, :activity_type, :attachment

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
          method: :put, data: { confirm: 'Are you sure you want to email & DM this feedback to all founders?' }
        )
      end
    end

    column :slack_feedback do |startup_feedback|
      link_to(
        'DM on Slack Now!',
        slack_feedback_admin_startup_feedback_path(startup_feedback),
        method: :put, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' }
      )
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
      row :attachment

      row :sent_at do |startup_feedback|
        if startup_feedback.sent_at.present?
          startup_feedback.sent_at
        else
          div do
            link_to(
              'Send Email to all founders.',
              email_feedback_admin_startup_feedback_path(startup_feedback),
              method: :put, data: { confirm: 'Are you sure you want to email this feedback to all founders?' },
              class: 'button'
            )
          end

          div(class: 'admin-startup-feedback-show-or') { 'OR' }

          div do
            render 'admin/startup_feedback/email_feedback_to_founder',
              form_path: email_feedback_to_founder_admin_startup_feedback_path,
              startup_feedback: startup_feedback
          end
        end
      end

      row :slack_feedback do |startup_feedback|
        div do
          link_to(
            'Send DM to all founders.',
            slack_feedback_admin_startup_feedback_path(startup_feedback),
            method: :put, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' },
            class: 'button'
          )
        end
        div(class: 'admin-startup-feedback-show-or') { 'OR' }

        div do
          render 'admin/startup_feedback/slack_feedback_to_founder',
            form_path: slack_feedback_to_founder_admin_startup_feedback_path,
            startup_feedback: startup_feedback
        end
      end
    end
  end

  form partial: 'admin/startup_feedback/form'

  member_action :email_feedback, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    StartupMailer.feedback_as_email(startup_feedback).deliver_later
    startup_feedback.update(sent_at: Time.now)
    redirect_to :back
  end

  member_action :slack_feedback, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    founders = startup_feedback.startup.founders

    # post to slack
    response = PublicSlackTalk.post_message message: startup_feedback.as_slack_message, founders: founders

    # show failure error if no response was received from PublicSlackTalk
    unless response.present?
      redirect_to :back, alert: 'Could not communicate with Slack. Try again'
      return
    end

    # form appropriate flash message with details from response
    success_names = Founder.find(founders.ids - response.errors.keys).map(&:slack_username).join(', ')
    failure_names = Founder.find(founders.ids & response.errors.keys).map(&:fullname).join(', ')
    success_message = success_names.present? ? "Your feedback has been sent as DM to: #{success_names} \n" : ''
    failure_message = failure_names.present? ? "Failed to ping: #{failure_names}" : ''
    flash[:alert] = success_message + failure_message

    redirect_to :back
  end

  member_action :email_feedback_to_founder, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    founder = Founder.find(params[:founder_id])
    StartupMailer.feedback_as_email(startup_feedback, founder: founder).deliver_later
    # Mark feedback as sent.
    startup_feedback.update(sent_at: Time.now)
    flash[:alert] = "Your feedback has been sent to #{founder.email}"
    redirect_to action: :show
  end

  member_action :slack_feedback_to_founder, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    founder = Founder.find(params[:founder_id])

    # post to slack
    response = PublicSlackTalk.post_message message: startup_feedback.as_slack_message, founder: founder

    # show failure error if no response was received from PublicSlackTalk
    unless response.present?
      redirect_to :back, alert: 'Could not communicate with Slack. Try again'
      return
    end

    flash[:alert] = if response.errors.any?
      "Could not ping #{founder.slack_username} on slack. Please try again"
    else
      "Your feedback has been sent as a DM to #{founder.slack_username} on slack"
    end
    redirect_to action: :show
  end

  action_item :email_feedback, only: :show, if: proc { startup_feedback.sent_at.blank? } do
    link_to(
      'Email Now!',
      email_feedback_admin_startup_feedback_path(startup_feedback),
      method: :put, data: { confirm: 'Are you sure you want to email this feedback to all founders?' }
    )
  end

  action_item :slack_feedback, only: :show do
    link_to(
      'DM on Slack Now!',
      slack_feedback_admin_startup_feedback_path(startup_feedback),
      method: :put, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' }
    )
  end
end
