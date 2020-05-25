ActiveAdmin.register TimelineEvent do
  actions :index, :show
  permit_params :improved_timeline_event_id, timeline_event_files_attributes: %i[id title file _destroy]

  filter :founders_user_name, as: :string
  filter :evaluated
  filter :created_at

  scope :from_admitted_startups, default: true
  scope :all

  config.sort_order = 'updated_at_desc'

  index do
    selectable_column

    column :product do |timeline_event|
      startup = timeline_event.startup

      a href: admin_startup_path(startup) do
        span startup.name
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

  collection_action :founders_for_startup do
    @startup = Startup.find params[:startup_id]
    render 'founders_for_startup.json.erb'
  end

  show do |timeline_event|
    div(class: 'admin-timeline_events__show')

    attributes_table do
      row :product do
        startup = timeline_event.startup

        a href: admin_startup_path(startup) do
          span startup.name
        end
      end

      row('Founder') { timeline_event.founder }
      row :evaluated

      row('Linked Target') do
        a href: admin_target_url(timeline_event.target) do
          timeline_event.target.title
        end
      end

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
          link_to timeline_event_file.filename, url_for(timeline_event_file.file), target: '_blank', rel: 'noopener'
        end
      end

      table_for timeline_event.links do
        column :url do |link|
          link_to link, target: '_blank', rel: 'noopener'
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
            pre feedback_entry.feedback
          end

          column(:created_at)
        end
      end
    end
  end
end
