ActiveAdmin.register Payment do
  menu parent: 'Admissions'
  actions :index, :show

  filter :batch_application
  filter :amount
  filter :fees

  index do
    column :batch_application do |payment|
      if payment.batch_application.present?
        link_to payment.batch_application.display_name, admin_batch_application_path(payment.batch_application)
      elsif payment.original_batch_application.present?
        em do
          link_to "#{payment.original_batch_application.display_name} (Archived)", admin_batch_application_path(payment.original_batch_application)
        end
      else
        em 'Missing'
      end
    end

    column :amount
    column :fees
    column(:status) { |payment| t("payment.status.#{payment.status}") }

    actions do |payment|
      if payment.batch_application.present?
        span do
          link_to(
            'Archive',
            archive_admin_payment_path(payment),
            class: 'member_link',
            method: :post,
            data: { confirm: 'Are you sure?' }
          )
        end
      end
    end
  end

  action_item :archive, only: :show do
    if payment.batch_application.present?
      link_to 'Archive', archive_admin_payment_path(payment), method: :post
    end
  end

  member_action :archive, method: :post do
    payment = Payment.find(params[:id])
    payment.archive!
    flash[:success] = "Payment ##{payment.id} has been archived!"
    redirect_to admin_payments_path
  end

  csv do
    column :application do |payment|
      "Application ##{payment.batch_application.id} to batch #{payment.batch_application.batch.batch_number}"
    end

    column :status do |payment|
      t("payment.status.#{payment.status}")
    end

    column :team_lead do |payment|
      team_lead = payment.batch_application.team_lead
      "#{team_lead.name} (#{team_lead.phone})"
    end

    column :amount

    column('Instamojo Fees', &:fees)
    column :paid_at
    column :created_at
  end
end
