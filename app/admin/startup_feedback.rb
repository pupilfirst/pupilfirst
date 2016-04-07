ActiveAdmin.register StartupFeedback do
  menu parent: 'Startups', label: 'Feedback'
  permit_params :feedback, :reference_url, :startup_id, :send_email, :faculty_id, :activity_type, :attachment, :event_id, :event_status

  preserve_default_filters!
  filter :startup_product_name, as: :select, collection: proc { Startup.all.order(:product_name).pluck(:product_name).uniq }

  controller do
    def scoped_collection
      super.includes :startup, :faculty
    end
  end

  # update timeline event status if included in feedback
  after_create do |startup_feedback|
    next unless startup_feedback.persisted?

    next unless startup_feedback.event_id.present? && startup_feedback.event_status.present?

    timeline_event = TimelineEvent.find(startup_feedback.event_id)
    next if timeline_event.verified_status == startup_feedback.event_status

    timeline_event.update!(verified_status: startup_feedback.event_status)
    TimelineEventVerificationNotificationJob.perform_later(timeline_event) if timeline_event.verified_or_needs_improvement?
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
      elsif startup_feedback.pending_email_to_founder?
        link_to(
          'Email Founder Now!',
          email_feedback_to_founder_admin_startup_feedback_path(id: startup_feedback.id, founder_id: startup_feedback.timeline_event.founder_id),
          method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founder?' }
        )
      else
        link_to(
          'Email Now!',
          email_feedback_admin_startup_feedback_path(startup_feedback),
          method: :put, data: { confirm: 'Are you sure you want to email & DM this feedback to all founders?' }
        )
      end
    end

    column :slack_feedback do |startup_feedback|
      if startup_feedback.for_founder?
        link_to(
          'DM Founder Now!',
          slack_feedback_to_founder_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
          method: :put, data: { confirm: 'Are you sure you want to DM this feedback to the founder on slack?' }
        )
      else
        link_to(
          'DM on Slack Now!',
          slack_feedback_admin_startup_feedback_path(startup_feedback),
          method: :put, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' }
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

      row :reference_url
      row :faculty
      row :attachment_file_name do |startup_feedback|
        if startup_feedback.attachment?
          span startup_feedback.attachment_file_name
          span class: 'wrap-with-paranthesis' do
            link_to 'Remove', remove_feedback_attachment_admin_startup_feedback_path(startup_feedback), method: :put, data: { confirm: 'Are you sure?' }
          end
          # a(href: remove_feedback_attachment_admin_startup_feedback_path(startup_feedback)) { 'Remove' }
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
              email_feedback_to_founder_admin_startup_feedback_path(id: startup_feedback.id, founder_id: startup_feedback.timeline_event.founder_id),
              method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founder?' },
              class: 'button'
            )
          end
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
        if startup_feedback.for_founder?
          founder = startup_feedback.timeline_event.founder
          div do
            link_to(
              "Send DM to founder (#{founder.fullname})",
              slack_feedback_to_founder_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
              method: :put, data: { confirm: 'Are you sure you want to DM this feedback to the founder on slack?' },
              class: 'button'
            )
          end
        else
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
  end

  form partial: 'admin/startup_feedback/form'

  member_action :email_feedback, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    StartupMailer.feedback_as_email(startup_feedback).deliver_later
    startup_feedback.update(sent_at: Time.now)
    redirect_to :back
  end

  member_action :remove_feedback_attachment, method: :put do
    startup_feedback = StartupFeedback.find params[:id]
    startup_feedback.attachment.remove!
    startup_feedback.save!
    redirect_to :back, alert: 'Attachment removed!'
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
    redirect_to :back
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
    redirect_to :back
  end

  action_item :email_feedback, only: :show, if: proc { startup_feedback.sent_at.blank? && !startup_feedback.for_founder? } do
    link_to(
      'Email Now!',
      email_feedback_admin_startup_feedback_path(startup_feedback),
      method: :put, data: { confirm: 'Are you sure you want to email this feedback to all founders?' }
    )
  end

  action_item :email_feedback_to_founder, only: :show, if: proc { startup_feedback.pending_email_to_founder? } do
    link_to(
      'Email Founder Now!',
      email_feedback_to_founder_admin_startup_feedback_path(id: startup_feedback.id, founder_id: startup_feedback.timeline_event.founder_id),
      method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founder?' }
    )
  end

  action_item :slack_feedback, only: :show, if: proc { !startup_feedback.for_founder? } do
    link_to(
      'DM on Slack Now!',
      slack_feedback_admin_startup_feedback_path(startup_feedback),
      method: :put, data: { confirm: 'Are you sure you want to DM this feedback to all founders on slack?' }
    )
  end

  action_item :slack_feedback, only: :show, if: proc { startup_feedback.for_founder? } do
    link_to(
      'DM Founder on Slack Now!',
      slack_feedback_to_founder_admin_startup_feedback_path(startup_feedback, founder_id: startup_feedback.timeline_event.founder_id),
      method: :put, data: { confirm: 'Are you sure you want to DM this feedback to the founder on slack?' }
    )
  end
end
