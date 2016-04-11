ActiveAdmin.register Target do
  permit_params :assignee_id, :assignee_type, :assigner_id, :role, :status, :title, :description, :status, :resource_url,
    :completion_instructions, :due_date_date, :due_date_time_hour, :due_date_time_minute, :slideshow_embed,
    :completed_at_date, :completed_at_time_hour, :completed_at_time_minute, :completion_comment, :rubric,
    :remote_rubric_url, :target_template_id

  scope :all
  scope :pending
  scope :expired

  preserve_default_filters!

  filter :assignee_type

  filter :assignee,
    if: proc { params.dig(:q, :assignee_type_eq).present? },
    collection: proc { Object.const_get(params.dig(:q, :assignee_type_eq)).joins(:targets).distinct }

  filter :role, as: :select, collection: Target.valid_roles
  filter :status, as: :select, collection: Target.valid_statuses

  controller do
    def create
      startup = Startup.find_by id: params[:target][:startup_id]

      @target = Target.new permitted_params[:target]
      @target.assignee = startup if startup.present?

      unless @target.valid?
        render :new
        return
      end

      if params.dig(:target, :role) == 'founder'
        # Then we're creating one of more founder targets.
        targets = create_multiple_founder_targets!
        flash[:success] = "Created #{targets.count} targets"
        redirect_to admin_targets_url
      else
        # Then we're just creating a single startup target.
        @target.save!
        AllTargetNotificationsJob.perform_later @target, 'new_target'
        flash[:success] = 'New target has been created.'
        redirect_to admin_target_url(@target)
      end
    end

    def create_multiple_founder_targets!
      founder_ids = params[:target][:founder_id].reject(&:blank?)
      startup = Startup.find_by_id params[:target][:startup_id]

      # Founders can either be all (of a startup), or selected list.
      founders = founder_ids.include?('all') ? startup.founders : Founder.where(id: founder_ids)

      founders.map do |founder|
        target = Target.create!(@target.attributes.merge(assignee: founder))
        AllTargetNotificationsJob.perform_later target, 'new_target'
      end
    end
  end

  member_action :duplicate, method: :get do
    target = Target.find(params[:id])
    redirect_to(
      new_admin_target_path(
        target: {
          role: target.role, title: target.title, description: target.description,
          resource_url: target.resource_url, completion_instructions: target.completion_instructions,
          due_date_date: target.due_date_date, due_date_time_hour: target.due_date.hour,
          due_date_time_minute: target.due_date.min
        }
      )
    )
  end

  action_item :duplicate, only: :show do
    link_to 'Duplicate', duplicate_admin_target_path(id: params[:id])
  end

  index do
    selectable_column

    column :assignee_type
    column :assignee

    column :role do |target|
      t("role.#{target.role}")
    end

    column :status do |target|
      if target.expired?
        'Expired'
      else
        t("target.status.#{target.status}")
      end
    end

    column :title
    column :assigner

    actions defaults: true do |target|
      link_to 'Duplicate', duplicate_admin_target_path(target)
    end
  end

  show do |target|
    if target.timeline_events.present?
      panel 'Linked Timeline Events' do
        table_for target.timeline_events.includes(:timeline_event_type) do
          column 'Timeline Event' do |timeline_event|
            a href: admin_timeline_event_path(timeline_event) do
              "##{timeline_event.id} #{timeline_event.title}"
            end
          end

          column :description
          column :verified?
          column :created_at
        end
      end
    end

    attributes_table do
      row :assignee_type
      row :assignee

      row :role do
        t("role.#{target.role}")
      end

      row :status do
        if target.expired?
          'Expired'
        else
          t("target.status.#{target.status}")
        end
      end

      row :title
      row :assigner
      row :target_template

      row :rubric do
        if target.rubric.present?
          link_to target.rubric_identifier, target.rubric.url
        end
      end

      row :description do
        target.description.html_safe
      end

      row :slideshow_embed
      row :resource_url
      row :completion_instructions
      row :due_date
      row :completed_at
      row :completion_comment
      row :created_at
      row :updated_at
    end
  end

  collection_action :founders_for_target do
    @founders = Startup.find(params[:startup_id]).founders
    render 'founders_for_target.json.erb'
  end

  form partial: 'admin/targets/form'
end
