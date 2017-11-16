ActiveAdmin.register TimelineEvent do
  include DisableIntercom

  permit_params :description, :timeline_event_type_id, :image, :event_on, :startup_id, :founder_id, :serialized_links,
    :improved_timeline_event_id, timeline_event_files_attributes: %i[id title file private _destroy]

  filter :startup_product_name, as: :string, label: 'Product Name'
  filter :startup_name, as: :string, label: 'Startup Name'
  filter :timeline_event_type_title, as: :string
  filter :timeline_event_type_role_eq, as: :select, collection: -> { TimelineEventType.valid_roles }, label: 'Role'
  filter :founder_name, as: :string
  filter :status, as: :select, collection: -> { TimelineEvent.valid_statuses }
  filter :grade, as: :select, collection: -> { TimelineEvent.valid_grades }
  filter :created_at
  filter :status_updated_at

  scope :from_admitted_startups, default: true
  scope :from_level_0_startups
  scope('Not Improved') { |scope| scope.needs_improvement.not_improved }
  scope :all

  config.sort_order = 'updated_at_desc'

  controller do
    def scoped_collection
      super.includes :startup, :timeline_event_type
    end
  end

  index do
    selectable_column
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

    column 'Founder', :founder

    column('Linked Target') do |timeline_event|
      if timeline_event.target.present?
        a href: admin_target_url(timeline_event.target) do
          timeline_event.target.title
        end
      end
    end

    column :status do |timeline_event|
      if timeline_event.verified?
        "Verified on #{timeline_event.status_updated_at.strftime('%d/%m/%y')}"
      elsif timeline_event.needs_improvement?
        "Marked needs improvement on #{timeline_event.status_updated_at.strftime('%d/%m/%y')}"
      else
        timeline_event.status
      end
    end

    actions
  end

  member_action :quick_review, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    if timeline_event.pending?
      status = {
        needs_improvement: TimelineEvent::STATUS_NEEDS_IMPROVEMENT,
        not_accepted: TimelineEvent::STATUS_NOT_ACCEPTED,
        verified: TimelineEvent::STATUS_VERIFIED
      }.fetch(params[:status].to_sym)

      points = params[:points].present? ? params[:points].to_i : nil

      begin
        TimelineEvents::VerificationService.new(timeline_event).update_status(status, grade: params[:grade], points: points)
        head :ok
      rescue TimelineEvents::ReviewInterfaceException => e
        render json: { error: e.message }.to_json, status: 422
      end
    else
      # someone else already reviewed this event! Ask javascript to reload page.
      render json: { error: 'Event no longer pending review! Refreshing your dashboard.' }.to_json, status: 422
    end
  end

  member_action :undo_review, method: :post do
    timeline_event = TimelineEvent.find(params[:id])

    unless timeline_event.reviewed?
      if params[:redirect] == 'true'
        flash[:success] = 'Event has not been reviewed. Undo is not possible.'
        redirect_to admin_timeline_event_path(timeline_event)
      else
        render json: { error: 'Event is pending review! Cannot undo.' }.to_json, status: 422
      end

      return
    end

    TimelineEvents::UndoVerificationService.new(timeline_event).execute

    if params[:redirect] == 'true'
      flash[:success] = 'Event has been restored to pending state.'
      redirect_to admin_timeline_event_path(timeline_event)
    else
      head :ok
    end
  end

  member_action :update_description, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    old_description = timeline_event.description
    timeline_event.update!(description: params[:description])
    TimelineEvents::DescriptionUpdateNotificationJob.perform_later(timeline_event, old_description)
    head :ok
  end

  member_action :get_attachment do
    timeline_event = TimelineEvent.find(params[:id])
    timeline_event_file = timeline_event.timeline_event_files.find_by(id: params[:timeline_event_file_id])

    raise_not_found if timeline_event_file.blank?

    redirect_to timeline_event_file.file.url
  end

  member_action :get_image do
    timeline_event = TimelineEvent.find(params[:id])
    redirect_to timeline_event.image.url
  end

  member_action :save_feedback, method: :post do
    raise if params[:feedback].blank?

    timeline_event = TimelineEvent.find(params[:id])

    feedback = StartupFeedback.create!(
      feedback: params[:feedback],
      startup: timeline_event.startup,
      faculty: current_admin_user&.faculty,
      timeline_event: timeline_event
    )

    founder_params = feedback.for_founder? ? { founder_id: feedback.timeline_event.founder.id } : {}

    render json: { feedback_id: feedback.id }.merge(founder_params)
  end

  member_action :send_slack_feedback, method: :post do
    startup_feedback = StartupFeedback.find(params[:feedback_id])
    founder = Founder.find(params[:founder_id]) if params[:founder_id].present?

    begin
      response = StartupFeedbackModule::SlackService.new(startup_feedback, founder: founder).send
    rescue StartupFeedbackModule::SlackService::CommunicationFailure
      render json: { error: 'Failed to communicate with Slack API' }, status: :internal_server_error
    else
      render json: { success: response }
    end
  end

  member_action :send_email_feedback, method: :post do
    startup_feedback = StartupFeedback.find(params[:feedback_id])
    founder = Founder.find(params[:founder_id]) if params[:founder_id].present?
    StartupFeedbackModule::EmailService.new(startup_feedback, founder: founder).send
    head :ok
  end

  action_item :review, only: :index do
    if current_admin_user&.superadmin?
      link_to 'Review Timeline Events', review_timeline_events_admin_timeline_events_path
    end
  end

  collection_action :review_timeline_events do
    if can? :quick_review, TimelineEvent
      @review_data = TimelineEvents::ReviewDataService.new.data
      @live_targets = Target.live.map { |target| { target.id => target.title } }
      render 'review_timeline_events'
    else
      flash[:error] = 'Not authorized to access page.'
      redirect_to admin_timeline_events_path
    end
  end

  action_item :view, only: :show do
    link_to('View Timeline Entry', timeline_event.share_url, target: '_blank')
  end

  action_item :view, only: :show, if: proc { timeline_event.reviewed? } do
    link_to('Undo Review', undo_review_admin_timeline_event_path(timeline_event, redirect: true), method: 'POST', data: { confirm: 'Are you sure? This will rollback all (possible) changes that were a result of the verification.' })
  end

  action_item :feedback, only: :show do
    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: timeline_event.startup.id,
          timeline_event_id: timeline_event.id
        }
      )
    )
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
      target = Target.find(params[:target_id])

      # Link the target to event.
      timeline_event.update(target: target)

      # Assign as improved_timeline_event, if applicable
      TimelineEvents::MarkAsImprovedTargetService.new(timeline_event).execute

      flash[:success] = 'Target has been linked.'
    else
      flash[:error] = 'A target must be picked for linking.'
    end

    redirect_to action: :show
  end

  collection_action :founders_for_startup do
    @startup = Startup.find params[:startup_id]
    render 'founders_for_startup.json.erb'
  end

  form do |f|
    div id: 'timeline-event-founders-for-startup-url', 'data-url' => founders_for_startup_admin_timeline_events_url
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Event Details' do
      f.input :startup,
        include_blank: true,
        label: 'Product'

      f.input :founder, label: 'Founder', as: :select, collection: f.object.persisted? ? f.object.startup.founders : [], include_blank: false
      f.input :timeline_event_type, include_blank: false
      f.input :description
      f.input :image
      f.input :event_on, as: :datepicker

      f.input :improved_timeline_event,
        as: :select,
        collection: f.object.persisted? ? f.object.improved_event_candidates.map { |e| "#{e.title} (#{e.event_on.strftime('%b %d')})" } : []

      f.input :serialized_links, as: :hidden
    end

    f.inputs 'Attached Files' do
      f.has_many :timeline_event_files, new_record: 'Add file', allow_destroy: true, heading: false do |t|
        t.input :title
        t.input :file, hint: 'Select new file for upload'
        t.input :private
      end
    end

    panel 'Attached Links', id: 'react-edit-attached-links' do
      react_component 'AATimelineEventLinksEditor', linksJSON: f.object.serialized_links
    end

    f.actions
  end

  show do |timeline_event|
    div(class: 'admin-timeline_events__show')

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

      row('Founder') { timeline_event.founder }
      row :iteration
      row :timeline_event_type
      row :description do
        simple_format(timeline_event.description)
      end

      row :image do
        if timeline_event.image.present?
          link_to timeline_event.image.url do
            image_tag timeline_event.image.url, width: '200px'
          end
        end
      end

      row :event_on
      row :share_on_facebook

      row :status

      row :status_updated_at

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
          t("models.timeline_event.grade.#{timeline_event.grade}")
        end
      end

      row :improved_timeline_event

      row :created_at
      row :updated_at
    end

    panel 'Attachments' do
      table_for timeline_event.timeline_event_files do
        column :title

        column :file do |timeline_event_file|
          link_to timeline_event_file.filename, timeline_event_file.file.url, target: '_blank'
        end

        column :private
      end

      table_for timeline_event.links do
        column :title do |link|
          link_to link[:title], link[:url], target: '_blank'
        end

        column :url do |link|
          link_to link[:url], link[:url], target: '_blank'
        end

        column :private do |link|
          link[:private] ? status_tag('Yes') : status_tag('No')
        end
      end
    end

    if timeline_event.target.blank?
      render partial: 'target_form', locals: { timeline_event: timeline_event }
    end

    feedback = StartupFeedback.for_timeline_event(timeline_event)

    if feedback.present?
      div do
        table_for feedback do
          caption 'Previous Feedback'
          column(:link) { |feedback_entry| link_to 'View', admin_startup_feedback_path(feedback_entry) }
          column(:faculty) { |feedback_entry| feedback_entry.faculty.name }

          column(:feedback) do |feedback_entry|
            feedback_entry.feedback.html_safe
          end

          column(:created_at)
        end
      end
    end
  end
end
