ActiveAdmin.register TimelineEvent do
  include DisableIntercom

  permit_params :description, :timeline_event_type_id, :image, :event_on, :startup_id,
    :founder_id, :serialized_links, :improved_timeline_event_id, timeline_event_files_attributes: [:id, :title, :file, :private, :_destroy]

  filter :startup_batch_id_eq, as: :select, collection: proc { Batch.all }, label: 'Batch'

  filter :startup, label: 'Product', collection: proc {
    batch_id = params.dig(:q, :startup_batch_id_eq)
    batch_id.present? ? Startup.where(batch_id: batch_id).order(:product_name) : Startup.all.order(:product_name)
  }

  filter :timeline_event_type, collection: proc { TimelineEventType.all.order(:title) }
  filter :timeline_event_type_role_eq, as: :select, collection: TimelineEventType.valid_roles, label: 'Role'

  filter :founder, collection: proc {
    batch_id = params.dig(:q, :startup_batch_id_eq)
    batch_id = Batch.last.id unless batch_id.present?
    Founder.joins(:startup).where(startups: { batch_id: batch_id }).distinct.order(:name)
  }

  filter :verified_status, as: :select, collection: TimelineEvent.valid_verified_status
  filter :grade, as: :select, collection: TimelineEvent.valid_grades
  filter :created_at
  filter :verified_at

  scope :all
  scope :batched
  scope :not_improved

  config.sort_order = 'updated_at_desc'

  controller do
    def scoped_collection
      super.includes :startup, :timeline_event_type
    end

    def show
      @status_update_form = Admin::TimelineEventStatusUpdateForm.new(TimelineEvent.find(params[:id]))
      super
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

    column :verified_status do |timeline_event|
      if timeline_event.verified?
        "Verified on #{timeline_event.verified_at.strftime('%d/%m/%y')}"
      elsif timeline_event.needs_improvement?
        "Marked needs improvement on #{timeline_event.verified_at.strftime('%d/%m/%y')}"
      else
        timeline_event.verified_status
      end
    end

    actions
  end

  member_action :quick_review, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    if timeline_event.pending?
      status = {
        needs_improvement: TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT,
        not_accepted: TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED,
        verified: TimelineEvent::VERIFIED_STATUS_VERIFIED
      }.fetch(params[:status].to_sym)

      points = params[:points].present? ? params[:points].to_i : nil

      TimelineEvents::VerificationService.new(timeline_event).update_status(status, grade: params[:grade], points: points)
      head :ok
    else
      # someone else already reviewed this event! Ask javascript to reload page.
      render json: { error: 'Event no longer pending review! Refreshing your dashboard.' }.to_json, status: 422
    end
  end

  member_action :update_description, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    timeline_event.update!(description: params[:description])
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
    raise unless params[:feedback].present?

    timeline_event = TimelineEvent.find(params[:id])
    reference_url = startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}")

    StartupFeedback.create!(
      feedback: params[:feedback],
      startup: timeline_event.startup,
      reference_url: reference_url,
      faculty: current_admin_user&.faculty
    )

    head :ok
  end

  action_item :review, only: :index do
    if current_admin_user&.superadmin?
      link_to 'Review Timeline Events', review_timeline_events_admin_timeline_events_path
    end
  end

  collection_action :review_timeline_events do
    if can? :quick_review, TimelineEvent
      batch = Batch.current
      @review_data = TimelineEvents::ReviewDataService.new(batch).data
      render 'review_timeline_events'
    else
      flash[:error] = 'Not authorized to access page.'
      redirect_to admin_timeline_events_path
    end
  end

  action_item :view, only: :show do
    link_to('View Timeline Entry', timeline_event.share_url, target: '_blank')
  end

  action_item :feedback, only: :show do
    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: timeline_event.startup.id,
          reference_url: startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}"),
          event_id: timeline_event.id
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

  member_action :update_status, method: :patch do
    timeline_event = TimelineEvent.find(params[:id])
    @status_update_form = Admin::TimelineEventStatusUpdateForm.new(timeline_event)

    if @status_update_form.validate(params[:admin_timeline_event_status_update])
      timeline_event, points = @status_update_form.save
      flash_message = "Timeline Event marked #{timeline_event.verified_status}"
      flash_message += " and #{points} Karma Points added" if points.present?
      flash[:success] = flash_message
      redirect_to action: :show
    else
      flash[:error] = "Status update failed!"
      render :show, layout: false
    end
  end

  member_action :save_link_as_resume_url, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    timeline_event.founder.update!(resume_url: timeline_event.links[params[:index].to_i][:url])
    flash[:success] = "Successfully updated founder's Resume URL."
    redirect_to action: :show
  end

  member_action :save_file_as_resume_url, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    file = timeline_event.timeline_event_files.find(params[:file_id])
    timeline_event.founder.update!(resume_url: download_startup_timeline_event_timeline_event_file_url(timeline_event.startup, timeline_event, file))
    flash[:success] = "Successfully updated founder's Resume URL."
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

      row :verified_status

      row :verified_at

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

      row :improved_timeline_event

      row :created_at
      row :updated_at
    end

    panel 'Attachments' do
      table_for timeline_event.timeline_event_files do
        column :title

        column :file do |timeline_event_file|
          link_to timeline_event_file.filename,
            download_startup_timeline_event_timeline_event_file_url(timeline_event.startup, timeline_event, timeline_event_file),
            target: '_blank'
        end

        column :private

        column :actions do |file|
          if timeline_event.timeline_event_type.resume_submission?
            link_to 'Save as Resume', save_file_as_resume_url_admin_timeline_event_path(file_id: file.id), method: :post, data: { confirm: 'Are you sure?' }
          end
        end
      end

      table_for timeline_event.links do
        column :title do |link|
          link_to link[:title], link[:url], target: '_blank'
        end

        column :url do |link|
          link_to link[:url], link[:url], target: '_blank'
        end

        column :private do |link|
          link[:private] ? status_tag('yes', :ok) : status_tag('no')
        end

        column :actions do |link|
          if timeline_event.timeline_event_type.resume_submission?
            index = timeline_event.links.find_index(link)
            link_to 'Save as Resume', save_link_as_resume_url_admin_timeline_event_path(index: index), method: :post, data: { confirm: 'Are you sure?' }
          end
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
