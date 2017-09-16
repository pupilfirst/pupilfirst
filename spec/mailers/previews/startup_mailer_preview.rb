class StartupMailerPreview < ActionMailer::Preview
  def startup_dropped_out
    startup = Startup.last
    StartupMailer.startup_dropped_out(startup)
  end

  def feedback_as_email
    startup_feedback = StartupFeedback.new(
      id: 1,
      feedback: "This is the feedback text.\nIt is multi-line.",
      timeline_event: TimelineEvent.new(
        id: 2,
        timeline_event_type: TimelineEventType.new(title: 'Timeline Event Type Title'),
        startup: Startup.new(id: 4, slug: 'test-startup')
        # target: Target.new
      ),
      faculty: Faculty.new(
        name: 'C V Raman'
      ),
      startup: Startup.new(
        id: 3,
        level: Level.new(number: 1)
      )
    )

    StartupMailer.feedback_as_email(startup_feedback)
  end

  def connect_request_confirmed
    connect_request = ConnectRequest.first

    StartupMailer.connect_request_confirmed(connect_request)
  end

  def payment_reminder
    payment = Payment.new(billing_end_at: 5.days.from_now, startup: Startup.last)
    StartupMailer.payment_reminder(payment)
  end

  def referral_reward
    referrer_startup = Startup.find_by(product_name: 'Super Product')
    referred_startup = Startup.find_by(product_name: 'Super Product')

    coupon = Coupon.new(referrer_startup: referrer_startup, referrer_extension_days: 10)

    # The final flag controls message related to reward_on_renewal.
    StartupMailer.referral_reward(referrer_startup, referred_startup, coupon, false)
  end
end
