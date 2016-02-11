ActiveAdmin.register TimelineEvent do
  menu parent: 'Startups'
  permit_params :description, :timeline_event_type_id, :image, :links, :event_on, :startup_id, :verified_at, :grade,
    :user_id

  preserve_default_filters!
  filter :startup_batch
  filter :startup_product_name, as: :select, collection: proc { Startup.all.pluck(:product_name).uniq }
  filter :timeline_event_type, collection: proc { TimelineEventType.all.order(:title) }

  scope :all
  scope :batched

  config.sort_order = 'updated_at_desc'

  controller do
    def scoped_collection
      super.includes :startup, :timeline_event_type
    end
  end

  index do
    selectable_column
    actions
    column :timeline_event_type

    column :product do |timeline_event|
      startup = timeline_event.startup

      a href: admin_startup_path(startup) do
        span startup.product_name

        if startup.name.present?
          span class: 'wrap-with-paranthesis' do
            startup.name
          end
        end
      end
    end

    column 'Founder', :user
    column :event_on

    column :verified_status do |timeline_event|
      if timeline_event.verified?
        "Verified on #{timeline_event.verified_at.strftime('%d/%m/%y')}"
      else
        timeline_event.verified_status
      end
    end
  end

  action_item :view, only: :show do
    link_to('View Timeline Entry', startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}"), target: '_blank')
  end

  action_item :feedback, only: :show do
    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: timeline_event.startup.id,
          reference_url: startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}")
        }
      )
    )
  end

  member_action :delete_link, method: :delete do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links.delete_at(params[:link_index].to_i)
    timeline_event.save!

    flash[:notice] = 'Link Deleted!'

    redirect_to action: :show
  end

  member_action :add_link, method: :post do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links << { title: params[:link_title], url: params[:link_url], private: params[:link_private] }
    timeline_event.save!

    flash[:success] = 'Link Added!'

    redirect_to action: :show
  end

  member_action :edit_link, method: :put do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links[params[:link_index].to_i] = { title: params[:link_title], url: params[:link_url], private: params[:link_private] }
    timeline_event.save!

    flash[:success] = 'Link Updated!'

    redirect_to action: :show
  end

  member_action :unlink_target, method: :post do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.update! target: nil
    flash[:success] = 'Target unlinked.'
    redirect_to action: :show
  end

  member_action :link_target, method: :post do
    timeline_event = TimelineEvent.find params[:id]

    # If a target has been picked, complete it.
    if params[:target_id].present?
      target = timeline_event.startup.targets.find(params[:target_id])

      # Link the target to event.
      timeline_event.update(target: target)

      Rails.logger.info event: :timeline_event_target_linked, target_id: target.id

      if params[:target_completed]
        target.complete!
        flash[:success] = 'Target has been linked and marked completed.'

        Rails.logger.info event: :timeline_event_target_completed, target_id: target.id
      else
        flash[:success] = 'Target has been linked.'
      end
    else
      flash[:error] = 'A target must be picked for linking.'
    end

    redirect_to action: :show
  end

  member_action :grade, method: :post do
    timeline_event = TimelineEvent.find params[:id]

    # If a grade has been picked, add that and create Karma Points.
    if params[:grade].present?
      timeline_event.update!(grade: params[:grade])

      # if private event, assign karma points to the founder too
      user = timeline_event.private? ? timeline_event.user : nil
      assigned_to = timeline_event.private? ? 'the founder and startup' : 'the startup' # used in flash message

      karma_point = KarmaPoint.create!(
        source: timeline_event,
        user: user,
        startup: timeline_event.startup,
        activity_type: "Added a new Timeline event - #{timeline_event.timeline_event_type.title}",
        points: timeline_event.points_for_grade
      )

      flash[:success] = "Karma points (#{timeline_event.points_for_grade}) have been assigned to #{assigned_to}."

      Rails.logger.info event: :timeline_event_karma_point_created, karma_point_id: karma_point.id
    else
      flash[:error] = 'A grade is required for processing.'
    end

    redirect_to action: :show
  end

  member_action :verify, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    startup = timeline_event.startup
    timeline_event.verify!

    unless timeline_event.timeline_event_type.private
      startup_url = Rails.application.routes.url_helpers.startup_url(startup)
      timeline_event_url = startup_url + "#event-#{timeline_event.id}"
      slack_message = "<#{startup_url}|#{startup.product_name}> has a new verified timeline entry:"\
      " <#{timeline_event_url}|#{timeline_event.timeline_event_type.title}>\n"
      slack_message += "*Description:* #{timeline_event.description}"

      # post to slack
      PublicSlackTalk.post_message message: slack_message, channel: '#general'
    end

    redirect_to action: :show
  end

  member_action :unverify, method: :post do
    TimelineEvent.find(params[:id]).unverify!
    redirect_to action: :show
  end

  member_action :mark_needs_improvement, method: :post do
    TimelineEvent.find(params[:id]).mark_needs_improvement!
    redirect_to action: :show
  end

  member_action :save_resume_url, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    timeline_event.user.update!(resume_url: timeline_event.links[params[:index].to_i][:url])
    flash[:success] = "Successfully updated user's resume URL."
    redirect_to action: :show
  end

  collection_action :founders_for_startup do
    @startup = Startup.find params[:startup_id]
    render 'founders_for_startup.json.erb'
  end

  form do |f|
    div id: 'timeline-event-founders-for-startup-url', 'data-url' => founders_for_startup_admin_timeline_events_url

    f.inputs 'Event Details' do
      f.input :startup,
        include_blank: true,
        label: 'Product',
        member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : ''}" }
      f.input :user, label: 'Founder', as: :select, collection: f.object.persisted? ? f.object.startup.founders : [], include_blank: false
      f.input :timeline_event_type, include_blank: false
      f.input :description
      f.input :image
      f.input :event_on, as: :datepicker
      f.input :verified_at, as: :datepicker
      f.input :grade, as: :select, collection: TimelineEvent.valid_grades, required: false
    end

    f.actions
  end

  show do |timeline_event|
    attributes_table do
      row :product do |startup|
        startup = timeline_event.startup

        a href: admin_startup_path(startup) do
          span startup.product_name

          if startup.name.present?
            span class: 'wrap-with-paranthesis' do
              startup.name
            end
          end
        end
      end

      row('Founder') { timeline_event.user }
      row :iteration
      row :timeline_event_type
      row :description

      row :image do
        if timeline_event.image.present?
          link_to timeline_event.image.url do
            image_tag timeline_event.image.url, width: '200px'
          end
        end
      end

      row :event_on
      row :verified_status

      row :verified_at do
        verification_confirm = 'Are you sure you want to verify this event?'
        verification_confirm += ' The Verification will be announced on Public Slack' unless timeline_event.timeline_event_type.private?
        if timeline_event.verified?
          span do
            "#{timeline_event.verified_at} "
          end

          span class: 'wrap-with-paranthesis' do
            link_to 'Unverify', unverify_admin_timeline_event_path, method: :post, data: { confirm: 'Are you sure you want to unverify this event?' }
          end
        elsif timeline_event.pending?
          span do
            button_to 'Unverified. Click to verify this event.', verify_admin_timeline_event_path,
              form_class: 'inline-button',
              data: { confirm:  verification_confirm }
          end

          span do
            button_to('Mark As Needs Improvement', mark_needs_improvement_admin_timeline_event_path, form_class: 'inline-button')
          end
        elsif timeline_event.needs_improvement?
          button_to 'Unverified. Click to verify this event.', verify_admin_timeline_event_path,
            data: { confirm:  verification_confirm }
        end
      end

      row('Linked Target') do
        if timeline_event.target.present?
          a href: admin_target_url(timeline_event.target) do
            timeline_event.target.title
          end

          span class: 'wrap-with-paranthesis' do
            link_to 'Unlink', unlink_target_admin_timeline_event_path, method: :post, data: { confirm: 'Are you sure?' }
          end
        end
      end

      row :karma_point

      row(:grade) do
        if timeline_event.grade.present?
          t("timeline_event.grade.#{timeline_event.grade}")
        end
      end

      row :created_at
      row :updated_at
    end

    if timeline_event.verified? && timeline_event.karma_point.blank?
      render partial: 'grade_form', locals: { timeline_event: timeline_event }
    end

    render partial: 'target_form', locals: { timeline_event: timeline_event }

    render partial: 'links', locals: { timeline_event: timeline_event }

    feedback = StartupFeedback.for_timeline_event(timeline_event)

    if feedback.present?
      div do
        table_for feedback do
          caption 'Previous Feedback'
          column(:link) { |feedback_entry| link_to 'View', admin_startup_feedback_path(feedback_entry) }
          column(:faculty) { |feedback_entry| feedback_entry.faculty.name }

          column(:feedback) do |feedback_entry|
            pre class: 'max-width-pre' do
              feedback_entry.feedback
            end
          end

          column(:created_at)
        end
      end
    end
  end
end
