ActiveAdmin.register Target do
  actions :all, except: [:destroy]

  permit_params :faculty_id, :role, :title, :description, :rubric_description, :resource_url, :completion_instructions, :days_to_complete,
    :slideshow_embed, :video_embed, :completed_at, :completion_comment, :link_to_complete, :archived, :target_group_id, :target_action_type,
    :sort_index, :youtube_video_id, :session_at, :session_by, :call_to_action,
    prerequisite_target_ids: [], tag_list: [], evaluation_criterion_ids: []

  filter :title
  filter :archived
  filter :session_at_not_null, as: :boolean, label: 'Session?'
  filter :target_group, collection: -> { TargetGroup.all.includes(:course, :level).order('courses.name ASC, levels.number ASC') }
  filter :level, collection: -> { Level.all.includes(:course).order('courses.name ASC, levels.number ASC') }
  filter :faculty_name, as: :string
  filter :role, as: :select, collection: -> { Target.valid_roles }
  filter :course, as: :select

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Target.tag_counts_on(:tags).pluck(:name).sort }

  scope :all, default: true
  scope :sessions

  controller do
    include DisableIntercom

    def scoped_collection
      super.includes(:course, :level, :target_group)
    end
  end

  index do
    selectable_column
    column :title

    column 'Target Group' do |target|
      if target.course.present?
        span do
          code "[#{target.course.short_name.rjust(3)}##{target.level.number}]"
          span target.target_group.name
        end
      else
        em "Not part of a course"
      end
    end

    column :type do |target|
      target.session? ? 'Session' : 'Target'
    end

    column :sort_index

    column :role do |target|
      t("models.target.role.#{target.role}")
    end

    actions
  end

  show do |target|
    if target.evaluation_criteria.present? && target.timeline_events.exists?
      div do
        table_for target.timeline_events.where(timeline_events: { created_at: 3.months.ago..Time.now }) do
          caption 'Linked Timeline Events (up to 3 months ago)'

          column 'Timeline Event' do |timeline_event|
            a href: admin_timeline_event_path(timeline_event) do
              "##{timeline_event.id} #{timeline_event.title}"
            end
          end

          column :status

          column :founder do |timeline_event|
            timeline_event.founder.display_name
          end

          column :startup do |timeline_event|
            timeline_event.startup.display_name
          end

          column :description
          column :created_at
        end
      end
    end

    attributes_table do
      row :title
      row :session_at

      row :tags do |founder|
        linked_tags(founder.tags)
      end

      row :prerequisite_targets do
        if target.prerequisite_targets.exists?
          ul do
            target.prerequisite_targets.each do |prerequisite_target|
              li do
                link_to prerequisite_target.title, admin_target_path(prerequisite_target)
              end
            end
          end
        end
      end

      row :level
      row :target_group
      row :sort_index
      row :target_action_type

      row :role do
        t("models.target.role.#{target.role}")
      end

      row 'Assigned by' do
        if target.faculty.present?
          link_to target.faculty.name, admin_faculty_path(target.faculty)
        end
      end

      row :description do
        target.description.html_safe
      end

      row :youtube_video_id do
        if target.youtube_video_id.present?
          span do
            code target.youtube_video_id
            span ' - '
            a(href: "https://www.youtube.com/watch?v=#{target.youtube_video_id}", target: '_blank') do
              'Open on YouTube'
            end
          end
        else
          em 'No YouTube Video ID available'
        end
      end

      row :video_embed
      row :slideshow_embed
      row :resource_url
      row :completion_instructions
      row :call_to_action
      row :days_to_complete
      row :completion_comment
      row :link_to_complete
      row :resubmittable
      row :rubric_description
      row :archived do
        div class: 'target-show__archival-status' do
          target.archived ? 'Yes' : 'No'
        end

        div class: 'target-show__archive-button' do
          span do
            if !target.archived?
              button_to(
                'Archive Target',
                archive_target_admin_target_path(target: { archived: true }),
                method: :put, data: { confirm: 'Are you sure you want to archive this target? This will wipe the pre-requisite mappings of this target if any' }
              )
            else
              button_to(
                'Unarchive Target',
                archive_target_admin_target_path(target: { archived: false }),
                method: :put, data: { confirm: 'Are you sure you want to unarchive this target?' }
              )
            end
          end
        end
      end

      row :created_at
      row :updated_at

      if target.target_evaluation_criteria.exists?
        div do
          table_for target.target_evaluation_criteria.includes(:evaluation_criterion) do
            caption 'Target Evaluation Criteria'

            column 'Criteria' do |ts|
              a href: admin_evaluation_criterion_path(ts.evaluation_criterion) do
                ts.evaluation_criterion.display_name.to_s
              end
            end
          end
        end
      end
    end
  end

  csv do
    column :id
    column :title

    column :session do |target|
      target.session? ? 'Yes' : 'No'
    end

    column :target_group do |target|
      target&.target_group&.name
    end

    column :level do |target|
      target.level&.display_name
    end

    column :target_action_type
    column :role

    column :faculty do |target|
      target&.faculty&.name
    end

    column :youtube_video_id
    column :video_embed
    column :slideshow_embed
    column :resource_url
    column :days_to_complete
    column :resubmittable
    column :archived do |target|
      target.archived? ? 'Yes' : 'No'
    end

    column :tags do |target|
      tags = ''
      target.tags&.each do |tag|
        tags += tag.name + ';'
      end
      tags
    end
  end

  action_item :invite_on_google_calendar, only: :show, if: proc { resource.session? } do
    link_to(
      'Invite on Google Calendar',
      invite_on_google_calendar_admin_target_url(id: params[:id]),
      method: :post, data: { confirm: 'Are you sure?' }
    )
  end

  member_action :invite_on_google_calendar, method: :post do
    target = Target.find params[:id]

    # Only the calender event needs to be created / updated manually.
    # Notifications and emails sent before and after the session are managed using periodic tasks.
    # See `lib/period_tasks.rake`.
    Targets::CreateOrUpdateCalendarEventJob.perform_later(target, current_admin_user)
    flash[:success] = "Google Calendar invitation will be created / updated shortly. You should receive an email in a few minutes with results."
    redirect_to admin_target_path(target)
  end

  member_action :archive_target, method: :put do
    target = Target.find params[:id]
    params = permitted_params[:target]

    service = Targets::ArchivalService.new(target)
    params[:archived] == 'true' ? service.archive : service.unarchive

    message_text = params[:archived] == 'true' ? 'archived' : 'unarchived'
    flash[:success] = "Target #{message_text} successfully!"
    redirect_to action: :show
  end

  form do |f|
    presenter = Admin::Targets::FormPresenter.new(target)
    div id: 'admin-target__edit'

    f.semantic_errors(*f.object.errors.keys)

    f.inputs name: 'Target Details' do
      f.input :role, as: :select, collection: Target.valid_roles.map { |r| [t("models.target.role.#{r}"), r] }, include_blank: false
      f.input :title
      f.input :session_at, as: :string, input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O' } }
      f.input :tag_list, as: :select, collection: Target.tag_counts_on(:tags).pluck(:name), multiple: true

      f.input :description, as: :hidden

      div class: 'label-replica' do
        text_node 'Description'
        abbr(title: 'required') { '*' }
      end

      insert_tag(Arbre::HTML::Div) { content_tag 'trix-editor', nil, class: 'input-replica' + ' ' + presenter.error_class, input: 'target_description' }

      if resource.errors[:description].present?
        para(class: 'inline-errors-replica') { resource.errors[:description][0] }
      end

      f.input :target_action_type, collection: Target.valid_target_action_types

      if presenter.valid_prerequisites.exists?
        f.input :prerequisite_targets, collection: presenter.valid_prerequisites
      end

      f.input :youtube_video_id, label: 'YouTube Video ID', placeholder: 'For eg. S0PEA3R-6TU'
      f.input :video_embed
      f.input :slideshow_embed
      f.input :resource_url
      f.input :completion_instructions
      f.input :call_to_action
      f.input :link_to_complete
      f.input :faculty, collection: Faculty.order(:name), include_blank: 'No linked faculty'
      f.input :target_group, collection: TargetGroup.all.includes(:course, :level).order('courses.name ASC, levels.number ASC')
      f.input :sort_index
      f.input :days_to_complete
      f.input :resubmittable
      f.input :evaluation_criteria, collection: EvaluationCriterion.all.map { |ec| [ec.display_name.to_s, ec.id] }
      f.input :rubric_description
    end

    f.actions
  end
end
