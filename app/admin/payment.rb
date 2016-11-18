ActiveAdmin.register Payment do
  include DisableIntercom

  menu parent: 'Admissions'
  actions :index, :show

  filter :batch_applicant_name_contains
  filter :amount
  filter :fees
  filter :refunded
  filter :created_at

  scope :all, default: true
  scope :requested
  scope :paid

  controller do
    def scoped_collection
      super.includes :batch_applicant, batch_application: [:batch, :team_lead]
    end
  end

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

    column :batch_applicant
    column :amount
    column :fees
    column(:status) { |payment| t("payment.status.#{payment.status}") }
    column :refunded

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

  action_item :mark_refunded, only: :show do
    unless payment.refunded?
      link_to 'Mark as Refunded', mark_refunded_admin_payment_path(payment), method: :post, data: { confirm: 'Are you sure?' }
    end
  end

  member_action :mark_refunded, method: :post do
    payment = Payment.find(params[:id])
    payment.refunded = true
    payment.save!
    flash[:success] = "Payment ##{payment.id} has been marked as refunded!"
    redirect_to admin_payments_path
  end

  csv do
    column :application do |payment|
      batch_application = payment.batch_application

      if batch_application.present?
        "Application ##{payment.batch_application.id} to batch #{payment.batch_application.batch.batch_number}"
      else
        'Missing'
      end
    end

    column :status do |payment|
      t("payment.status.#{payment.status}")
    end

    column :team_lead do |payment|
      team_lead = payment&.batch_application&.team_lead || payment.batch_applicant
      "#{team_lead.name} (#{team_lead.phone})" if team_lead.present?
    end

    column :amount
    column('Instamojo Fees', &:fees)
    column :paid_at
    column :created_at
    column :notes
  end
end
