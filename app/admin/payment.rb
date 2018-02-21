ActiveAdmin.register Payment do
  include DisableIntercom

  menu parent: 'Admissions'
  config.clear_action_items!
  actions :all, except: %i[destroy edit]

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

  action_item :new_payment, only: :index do
    if current_admin_user&.superadmin?
      link_to 'New Payment', new_payment_admin_payments_path
    end
  end

  action_item :edit_payment, only: :show do
    if current_admin_user&.superadmin?
      link_to 'Edit Payment', edit_payment_admin_payment_path(id: resource.id)
    end
  end

  collection_action :new_payment do
    form = Admin::PaymentForm.new(Payment.new)
    render 'admin/payments/form', locals: { form: form }
  end

  member_action :edit_payment do
    form = Admin::PaymentForm.new(Payment.find(params[:id]))
    @founder = Founder.find(form.founder_id)
    render 'admin/payments/form', locals: { form: form }
  end

  collection_action :create_payment, method: :post do
    form = Admin::PaymentForm.new(Payment.new)

    if form.validate(params[:admin_payment])
      payment = form.save
      flash[:success] = "Payment successfully created."
      redirect_to admin_payment_path(payment)
    else
      render 'admin/payments/form', locals: { form: form }
    end
  end

  member_action :update_payment, method: :patch do
    form = Admin::PaymentForm.new(Payment.find(params[:id]))

    if form.validate(params[:admin_payment])
      form.save
      flash[:success] = "Payment ##{params[:id]} has been updated successfully."
      redirect_to admin_payment_path(id: params[:id])
    else
      render 'admin/payments/form', locals: { form: form }
    end
  end

  permit_params :amount, :paid_at, :notes, :founder_id, :startup_id, :payment_type
end
