ActiveAdmin.register BatchApplication do
  menu parent: 'Batches', label: 'Applications', priority: 0

  permit_params :batch_id, :application_stage_id, :university_id, :product_name, :team_achievement, :team_lead_id

  batch_action :promote, confirm: 'Are you sure?' do |ids|
    promoted = 0

    BatchApplication.where(id: ids).each do |batch_application|
      if batch_application.promotable?
        batch_application.promote!
        promoted += 1
      end
    end

    flash[:success] = "#{promoted} #{'application'.pluralize(promoted)} successfully promoted!"

    redirect_to collection_path
  end

  index do
    selectable_column

    column :batch

    column :team_lead do |batch_application|
      team_lead = batch_application.team_lead

      if team_lead.present?
        link_to team_lead.name, admin_batch_applicant_path(team_lead)
      else
        em 'Deleted'
      end
    end

    column :product_name
    column 'Stage', :application_stage

    column 'Submission' do |batch_application|
      current_stage = batch_application.application_stage
      submission = batch_application.application_submissions.find_by(application_stage_id: current_stage.id)

      if submission.present?
        link_to "#{current_stage.name} submission", admin_application_submission_path(submission)
      end
    end

    column :score

    actions do |batch_application|
      if batch_application.promotable?
        span do
          link_to 'Promote', promote_admin_batch_application_path(batch_application), method: :post, class: 'member_link'
        end
      end
    end
  end

  member_action :promote, method: :post do
    batch_application = BatchApplication.find(params[:id])
    promoted_stage = batch_application.promote!
    flash[:success] = "Application has been promoted to #{promoted_stage.name}"
    redirect_to admin_batch_applications_path
  end

  action_item :promote, only: :show do
    if batch_application.promotable?
      link_to('Promote to next stage', promote_admin_batch_application_path(batch_application), method: :post)
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :batch
      f.input :team_lead
      f.input :application_stage, collection: ApplicationStage.all.order(number: 'ASC')
      f.input :product_name
      f.input :team_achievement
    end

    f.actions
  end
end
