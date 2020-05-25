ActiveAdmin.register Target do
  actions :index, :show

  filter :title
  filter :archived
  filter :session_at_not_null, as: :boolean, label: 'Session?'
  filter :target_group, collection: -> { TargetGroup.all.includes(:course, :level).order('courses.name ASC, levels.number ASC') }
  filter :level, collection: -> { Level.all.includes(:course).order('courses.name ASC, levels.number ASC') }
  filter :faculty_user_name, as: :string
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
end
