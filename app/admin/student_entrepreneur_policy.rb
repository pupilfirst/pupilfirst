ActiveAdmin.register StudentEntrepreneurPolicy do
  menu label: "SEP"

  member_action :sep_email, method: :post do
    sep = StudentEntrepreneurPolicy.find params[:id]
    SendSepJob.new.async.perform(sep.id)
    sep.update_attributes!({status: true})
    redirect_to action: :show
  end

  index do
    column :id do |sep|
      link_to sep.id, admin_student_entrepreneur_policy_path(sep)
    end
    column :picture do |sep|
      image_tag(sep.certificate_pic_url(:thumb))
    end

    column :fullname do |sep|
      sep.user.fullname
    end
    column :college do |sep|
      sep.user.college
    end

    column :course do |sep|
      sep.user.course
    end

    column :company_name do |sep|
      sep.user.startup.name
    end

    column :designation do |sep|
      sep.user.title
    end

    column :semester do |sep|
      sep.user.semester
    end

    column :university do |sep|
      sep.user.university
    end
    column :status
    column :created_at
  end

  show do
    attributes_table do

      row :picture do |sep|
        image_tag(sep.certificate_pic_url(:thumb))
      end

      row :fullname do |sep|
        sep.user.fullname
      end

      row :date_of_birth do |sep|
        sep.user.born_on
      end

      row :gender do |sep|
        sep.user.gender
      end

      row :college do |sep|
        sep.user.college
      end

      row :course do |sep|
        sep.user.course
      end

      row :company_name do |sep|
        sep.user.startup.name
      end

      row :designation do |sep|
        sep.user.title
      end

      row :semester do |sep|
        sep.user.semester
      end

      row :university do |sep|
        sep.user.university
      end

      row :university_registration_number do |sep|
        sep.university_registration_number
      end

      row :address do |sep|
        sep.address
      end

      row :approval_status do |sep|
        sep.status
      end

      row :action do |sep|
          link_to("Approve & send certificate",
                  sep_email_admin_student_entrepreneur_policy_path,
                  { method: :post, data: { confirm: "Are you sure?" } })

      end
    end
    active_admin_comments
  end

end
