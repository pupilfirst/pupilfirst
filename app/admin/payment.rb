ActiveAdmin.register Payment do
  include DisableIntercom

  menu parent: 'Admissions'
  actions :index, :show

  filter :founder_name, as: :string
  filter :amount
  filter :fees
  filter :refunded
  filter :created_at

  scope :all, default: true
  scope :requested
  scope :paid

  index do
    column :startup do |payment|
      if payment.startup.present?
        link_to payment.startup.product_name, admin_startup_path(payment.startup)
      else
        em 'Missing'
      end
    end

    column :founder do |payment|
      if payment.founder.present?
        link_to payment.founder.name, admin_founder_path(payment.founder)
      else
        em 'Missing'
      end
    end

    column :amount
    column(:status) { |payment| t("models.payment.status.#{payment.status}") }
    column :refunded

    actions
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
    column :startup do |payment|
      startup = payment.startup
      "Startup ##{payment.startup.id} - #{payment.startup.product_name}" if startup.present?
    end

    column :status do |payment|
      t("models.payment.status.#{payment.status}")
    end

    column :founder do |payment|
      founder = payment.founder
      "#{founder.name} (#{founder.phone})" if founder.present?
    end

    column :amount
    column('Instamojo Fees', &:fees)
    column :paid_at
    column :created_at
    column :notes
  end
end
