ActiveAdmin.register Payment do
  include DisableIntercom

  menu parent: 'Admissions'
  actions :all, except: [:destroy]

  filter :founder_name, as: :string
  filter :amount
  filter :fees
  filter :payment_type, as: :select, collection: Payment.valid_payment_types
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

    actions
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

  form do |f|
    div id: 'admin-payment__form'

    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Payment Details' do
      f.input :amount
      f.input :paid_at, as: :datepicker
      f.input :notes
      f.input :founder, label: 'Team Member', collection: f.object.founder.present? ? [f.object.founder] : []
      f.input :payment_type, as: :select, collection: Payment.valid_payment_types
    end

    f.actions
  end

  permit_params :amount, :paid_at, :notes, :founder_id, :startup_id, :payment_type
end
