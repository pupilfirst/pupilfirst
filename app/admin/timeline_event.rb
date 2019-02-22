ActiveAdmin.register TimelineEvent do
  actions :all, except: [:edit]
  permit_params :description, :event_on, :serialized_links,
    :improved_timeline_event_id, timeline_event_files_attributes: %i[id title file_as private _destroy]

  filter :founders_name, as: :string
  filter :evaluated
  filter :created_at

  scope :from_admitted_startups, default: true
  scope :all

  config.sort_order = 'updated_at_desc'

  controller do
    include DisableIntercom
  end

  index do
    selectable_column

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
      a href: admin_target_url(timeline_event.target) do
        timeline_event.target.title
      end
    end

    column :evaluated

    actions
  end

  member_action :update_description, method: :post do
    timeline_event = TimelineEvent.find(params[:id])
    old_description = timeline_event.description
    timeline_event.update!(description: params[:description])
    TimelineEvents::DescriptionUpdateNotificationJob.perform_later(timeline_event, old_description)
    head :ok
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

  # action_item :review, only: :index do
  #   if current_admin_user&.superadmin?
  #     link_to 'Review Timeline Events', review_timeline_events_admin_timeline_events_path
  #   end
  # end

  action_item :view, only: :show do
    link_to('View Timeline Entry', timeline_event.share_url, target: '_blank', rel: 'noopener')
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
      f.input :description
      f.input :event_on, as: :datepicker

      f.input :improved_timeline_event,
        as: :select,
        collection: f.object.persisted? ? f.object.improved_event_candidates.map { |e| "#{e.title} (#{e.event_on.strftime('%b %d')})" } : []

      f.input :serialized_links, as: :hidden
    end

    f.inputs 'Attached Files' do
      f.has_many :timeline_event_files, new_record: 'Add file', allow_destroy: true, heading: false do |t|
        t.input :title
        t.input :file_as, hint: 'Select new file for upload'
        t.input :private
      end
    end

    panel 'Attached Links', id: 'react-edit-attached-links' do
      react_component 'TimelineEventLinksEditor', linksJSON: f.object.serialized_links
    end

    f.actions
  end

  show do |timeline_event|
    div(class: 'admin-timeline_events__show')

    attributes_table do
      row :product do
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
      row :description do
        simple_format(timeline_event.description)
      end

      row :event_on
      row :evaluated

      row('Linked Target') do
        a href: admin_target_url(timeline_event.target) do
          timeline_event.target.title
        end
      end

      row :karma_point
      row :score
      row('Grade') do
        timeline_event.overall_grade_from_score if timeline_event.score.present?
      end
      row :improved_timeline_event
      row :created_at
      row :updated_at
    end

    panel 'Attachments' do
      table_for timeline_event.timeline_event_files do
        column :title

        column :file do |timeline_event_file|
          link_to timeline_event_file.filename, url_for(timeline_event_file.file_as), target: '_blank', rel: 'noopener'
        end

        column :private
      end

      table_for timeline_event.links do
        column :title do |link|
          link_to link[:title], link[:url], target: '_blank', rel: 'noopener'
        end

        column :url do |link|
          link_to link[:url], link[:url], target: '_blank', rel: 'noopener'
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
