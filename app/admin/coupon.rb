ActiveAdmin.register Coupon do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :code, :discount_percentage, :expires_at, :redeem_limit,
    :instructions, :user_extension_days

  filter :validity_in, as: :select, collection: %w[Valid Invalid], label: 'Validity'

  scope :all
  scope :referral

  index do
    selectable_column

    column :code
    column :user_extension_days
    column :referrer_extension_days
    column :expires_at
    column :redeem_limit
    column :referrer_startup

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Coupon Details' do
      f.input :code, hint: 'The code that must be entered to activate this coupon. Length: 4-10'
      f.input :user_extension_days, hint: 'The extra subscription days gained from using the coupon'
      f.input :expires_at, as: :datepicker, hint: 'The date at which the coupon will be disabled. Leave this as blank to create a coupon that never expires.'
      f.input :redeem_limit, hint: 'The number of times this coupon can be used. Set it to zero to allow infinite redeems.'
      f.input :instructions
    end

    f.actions
  end
end
