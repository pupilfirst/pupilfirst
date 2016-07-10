ActiveAdmin.register Payment do
  menu parent: 'Batches'
  actions :index, :show, :destroy

  filter :batch_application
  filter :amount
  filter :fees

  index do
    column :batch_application
    column :amount
    column :fees
    column(:status) { |payment| t("payment.status.#{payment.status}") }
    actions
  end

  csv do
    column :application do |payment|
      "Application ##{payment.batch_application.id} to batch #{payment.batch_application.batch.batch_number}"
    end

    column :status do |payment|
      t("payment.status.#{payment.status}")
    end

    column :amount

    column('Instamojo Fees', &:fees)
    column :paid_at
    column :created_at
  end
end
