ActiveAdmin.register ProspectiveApplicant do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :name, :email, :phone, :college_id

  filter :name
  filter :email
  filter :phone
  filter :created_at

  index do
    selectable_column

    column :name
    column :email
    column :phone

    column :college do |prospective_applicant|
      if prospective_applicant.college.present?
        link_to prospective_applicant.college.name, admin_college_path(prospective_applicant.college)
      else
        prospective_applicant.college_text
      end
    end

    actions
  end
end
