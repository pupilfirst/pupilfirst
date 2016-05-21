ActiveAdmin.register BatchApplication do
  menu parent: 'Batches', label: 'Applications', priority: 0

  permit_params :batch_id, :application_stage_id, :university_id, :product_name, :team_achievement

  index do
    selectable_column

    column :team_lead do |batch_application|
      team_lead = batch_application.team_lead
      link_to team_lead.name, admin_batch_applicant_path(team_lead)
    end

    column :product_name
    column :application_stage
    column :score

    actions do |batch_application|
      span do
        link_to 'Promote', promote_admin_batch_application_path(batch_application), method: :post, class: 'member_link'
      end
    end
  end

  member_action :promote, method: :post do
    batch_application = BatchApplication.find(params[:id])
    promoted_stage = batch_application.promote!
    flash[:success] = "Application has been promoted to #{promoted_stage.name}"
    redirect_to admin_batch_applications_path
  end
end
