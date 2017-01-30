ActiveAdmin.register CouponUsage do
  include DisableIntercom

  menu parent: 'Admissions'

  actions :index, :show

  scope :all
  scope :redeemed

  controller do
    def scoped_collection
      # TODO: More N+1 queries to avoid here
      super.includes(:coupon)
    end
  end

  index do
    column :coupon
    column :batch_application
    column :redeemed_at do |coupon_usage|
      coupon_usage.redeemed_at || 'Not Redeemed'
    end

    actions
  end
end
