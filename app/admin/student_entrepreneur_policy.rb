ActiveAdmin.register StudentEntrepreneurPolicy do
  menu label: 'SEP', parent: 'Defunct'

  member_action :sep_email, method: :post do
    sep = StudentEntrepreneurPolicy.find params[:id]
    Delayed::Job.enqueue SendSepJob.new(sep.id)
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
      sep.user.try(:fullname)
    end
    column :college do |sep|
      sep.user.try(:college)
    end

    column :course do |sep|
      sep.user.try(:course)
    end

    column :company_name do |sep|
      sep.user.try(:startup).try(:name)
    end

    column :designation do |sep|
      sep.user.try(:title)
    end

    column :semester do |sep|
      sep.user.try(:semester)
    end

    column :university do |sep|
      sep.user.try(:university)
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
        sep.user.try(:fullname)
      end

      row :date_of_birth do |sep|
        sep.user.try(:born_on)
      end

      row :gender do |sep|
        sep.user.try(:gender)
      end

      row :college do |sep|
        sep.user.try(:college)
      end

      row :course do |sep|
        sep.user.try(:course)
      end

      row :company_name do |sep|
        sep.user.try(:startup).try(:name)
      end

      row :designation do |sep|
        sep.user.try(:title)
      end

      row :semester do |sep|
        sep.user.try(:semester)
      end

      row :university do |sep|
        sep.user.try(:university)
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
  end

end
