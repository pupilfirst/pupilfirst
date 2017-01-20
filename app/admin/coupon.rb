ActiveAdmin.register Coupon do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :code, :coupon_type, :discount_percentage, :expires_at, :redeem_limit

  filter :coupon_type

  index do
    selectable_column

    column :code
    column :coupon_type
    column :discount_percentage
    column :expires_at
    column :redeem_limit

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Coupon Details' do
      f.input :code
      f.input :coupon_type, as: :select, collection: Coupon.valid_coupon_types
      f.input :discount_percentage
      f.input :expires_at, as: :datepicker
      f.input :redeem_limit
    end

    f.actions
  end
end
