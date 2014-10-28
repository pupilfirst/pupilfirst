ActiveAdmin.register Partnership do
  controller do
    newrelic_ignore
  end

  filter :user
  filter :startup
  filter :share_percentage
  filter :cash_contribution
  filter :confirmed_at_not_null, as: :boolean, label: 'Confirmed'
  filter :confirmed_at_null, as: :boolean, label: 'Unconfirmed'

  index do
    selectable_column
    column :user
    column :startup
    column :share_percentage
    column :cash_contribution
    column :confirmed_at
    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :user
      f.input :startup
      f.input :share_percentage
      f.input :cash_contribution
      f.input :salary
      f.input :managing_director
      f.input :operate_bank_account
    end
    f.actions
  end

  permit_params :user_id, :startup_id, :share_percentage, :salary, :cash_contribution, :managing_director,
    :operate_bank_account
end
