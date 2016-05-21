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

    actions
  end
end
