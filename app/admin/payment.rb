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
    column(:status) { |payment| t("en.payment.status.#{payment.status}") }
    actions
  end
end
