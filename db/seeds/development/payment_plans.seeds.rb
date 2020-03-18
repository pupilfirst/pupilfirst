after 'development:courses' do
  puts 'Seeding payment plans'

  # We'll pick one of the two courses we seeded and give it three plans - two of which are showcased.
  course = Course.first

  # The first plan is free, but short-term - something like a trial.
  free_plan = FreePlan.create!(duration: 1)

  course.payment_plans.create(
    plan: free_plan,
    name: 'Trial',
    description: "This is a free, one-month trial for the course.",
    showcase: true
  )

  # The second plan is a monthly subscription plan.
  subscription_plan = SubscriptionPlan.create!(interval: 'month', interval_count: 1, amount: 1000)

  course.payment_plans.create(
    plan: subscription_plan,
    name: 'Subscription',
    description: "This is the monthly subscription plan for the course.",
    showcase: true
  )

  # The non-showcased plan is a one-time-purchase plan for custom use.
  one_time_purchase_plan = OneTimePurchasePlan.create!(duration: 6, amount: 4000)

  course.payment_plans.create(
    plan: one_time_purchase_plan,
    name: 'Subscription',
    description: "This is a 6-month plan that offers a ~33% discount.",
    showcase: false
  )
end
