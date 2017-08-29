ActiveAdmin.register StartupFeedback do
  include DisableIntercom

  menu parent: 'Startups', label: 'Feedback'
  permit_params :feedback, :reference_url, :startup_id, :send_email, :faculty_id, :activity_type, :attachment, :timeline_event_id

  filter :startup_product_name, as: :string
  filter :startup_name, as: :string
  filter :faculty_name, as: :string
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
      startup_feedback.feedback.html_safe
    end

    column :timeline_event
    column :faculty
    column :created_at

    column :sent_at do |startup_feedback|
      if startup_feedback.sent_at.present?
        startup_feedback.sent_at
      elsif startup_feedback.for_founder?
        link_to(
          'Email Founder Now',
          email_feedback_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
          method: :post, data: { confirm: 'Are you sure you want to email this feedback to the founder?' }
        )
      else
        link_to(
          'Email Now',
          email_feedback_admin_startup_feedback_path(startup_feedback),
          method: :post, data: { confirm: 'Are you sure you want to email & DM this feedback to all founders?' }
        )
      end
    end

    column :slack_feedback do |startup_feedback|
      if startup_feedback.for_founder?
        link_to(
          'DM Founder Now',
          slack_feedback_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
          method: :post, data: { confirm: 'Are you sure you want to DM this feedback to the founder on slack?' }
        )
      else
        link_to(
          'DM on Slack Now',
          slack_feedback_admin_startup_feedback_path(startup_feedback),
          method: :post, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' }
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
        startup_feedback.feedback.html_safe
      end

      row :activity_type
      row :timeline_event

      row :reference_url
      row :faculty

      row :attachment do |startup_feedback|
        if startup_feedback.attachment?
          span do
            link_to startup_feedback.attachment_file_name, startup_feedback.attachment_url
          end

          span class: 'wrap-with-paranthesis' do
            link_to 'Remove', remove_feedback_attachment_admin_startup_feedback_path(startup_feedback), method: :put, data: { confirm: 'Are you sure?' }
          end
        end
      end

      row :sent_at do |startup_feedback|
        if startup_feedback.sent_at.present?
          startup_feedback.sent_at
        elsif startup_feedback.for_founder?
          founder = startup_feedback.timeline_event.founder
          div do
            link_to(
              "Send Email to founder (#{founder.fullname})",
              email_feedback_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
              method: :post, data: { confirm: 'Are you sure you want to email this feedback to the founder?' },
              class: 'button'
            )
          end
        else
          div do
            link_to(
              'Send Email to all founders.',
              email_feedback_admin_startup_feedback_path(startup_feedback),
              method: :post, data: { confirm: 'Are you sure you want to email this feedback to all founders?' },
              class: 'button'
            )
          end

          div(class: 'admin-startup-feedback-show-or') { 'OR' }

          div do
            render 'admin/startup_feedback/email_feedback',
              form_path: email_feedback_admin_startup_feedback_path,
              startup_feedback: startup_feedback
          end
        end
      end

      row :slack_feedback do |startup_feedback|
        if startup_feedback.for_founder?
          founder = startup_feedback.timeline_event.founder
          div do
            link_to(
              "Send DM to founder (#{founder.fullname})",
              slack_feedback_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
              method: :post, data: { confirm: 'Are you sure you want to DM this feedback to the founder on slack?' },
              class: 'button'
            )
          end
        else
          div do
            link_to(
              'Send DM to all founders.',
              slack_feedback_admin_startup_feedback_path(startup_feedback),
              method: :post, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' },
              class: 'button'
            )
          end
          div(class: 'admin-startup-feedback-show-or') { 'OR' }

          div do
            render 'admin/startup_feedback/slack_feedback',
              form_path: slack_feedback_admin_startup_feedback_path,
              startup_feedback: startup_feedback
          end
        end
      end
    end
  end

  form partial: 'admin/startup_feedback/form'

  member_action :email_feedback, method: :post do
    startup_feedback = StartupFeedback.find params[:id]
    founder = Founder.find(params[:founder_id]) if params[:founder_id].present?

    StartupFeedbackModule::EmailService.new(startup_feedback, founder: founder).send

    message_target = founder.present? ? founder.email : 'all founders'
    flash[:alert] = "Your feedback has been sent to #{message_target}"

    redirect_back(fallback_location: admin_startup_feedback_index_url)
  end

  member_action :slack_feedback, method: :post do
    startup_feedback = StartupFeedback.find params[:id]
    founder = Founder.find(params[:founder_id]) if params[:founder_id].present?

    begin
      response = StartupFeedbackModule::SlackService.new(startup_feedback, founder: founder).send
      flash[:alert] = response
    end

    redirect_back(fallback_location: admin_startup_feedback_index_url)
  end

  member_action :remove_feedback_attachment, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    startup_feedback.attachment.remove!
    startup_feedback.save!
    flash[:success] = 'Attachment removed!'
    redirect_back(fallback_location: admin_startup_feedback_index_url)
  end

  action_item :email_feedback, only: :show, if: proc { startup_feedback.sent_at.blank? && !startup_feedback.for_founder? } do
    if startup_feedback.for_founder?
      link_to(
        'Email Founder Now!',
        email_feedback_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
        method: :post, data: { confirm: 'Are you sure you want to email this feedback to the founder?' }
      )
    else
      link_to(
        'Email Now!',
        email_feedback_admin_startup_feedback_path(startup_feedback),
        method: :post, data: { confirm: 'Are you sure you want to email this feedback to all founders?' }
      )
    end
  end

  action_item :slack_feedback, only: :show do
    if startup_feedback.for_founder?
      link_to(
        'DM Founder on Slack Now!',
        slack_feedback_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
        method: :post, data: { confirm: 'Are you sure you want to DM this feedback to the founder on slack?' }
      )
    else
      link_to(
        'DM on Slack Now!',
        slack_feedback_admin_startup_feedback_path(startup_feedback),
        method: :post, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' }
      )
    end
  end
end
