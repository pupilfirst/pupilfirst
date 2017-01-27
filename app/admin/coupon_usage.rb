ActiveAdmin.register CouponUsage do
  include DisableIntercom

  menu parent: 'Admissions'

  actions :index, :show

  scope :all
  scope :redeemed

  index do
    column :coupon
    column :batch_application
    column :redeemed_at do |coupon_usage|
      coupon_usage.redeemed_at || 'Not Redeemed'
    end

    actions
  end
end
