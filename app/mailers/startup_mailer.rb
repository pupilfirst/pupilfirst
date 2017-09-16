# Mails sent out to startups, as a whole.
class StartupMailer < ApplicationMailer
  def startup_dropped_out(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Your Startup has Dropped Out')
  end

  def feedback_as_email(startup_feedback, founder: nil)
    @startup_feedback = startup_feedback
    send_to = founder&.email || startup_feedback.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Feedback from Team SV')
  end

  # Mail sent to startup founders once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    send_to = connect_request.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Connect Request confirmed.')
  end

  def payment_reminder(payment)
    @payment = payment
    send_to = payment.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: "Your SV.CO subscription expires in #{payment.days_to_expiry} days.")
  end

  # @param referrer_startup [Startup] Startup receiving referral reward
  # @param referred_startup [Startup] Startup that joined using the referral coupon
  # @param coupon [Coupon] Referral coupon that was used
  # @param reward_on_renewal [TrueClass, FalseClass] Boolean - whether reward will be delivered on renewal of subscription, or has already been rewarded.
  def referral_reward(referrer_startup, referred_startup, coupon, reward_on_renewal)
    @referrer_startup = referrer_startup
    @referred_startup = referred_startup
    @coupon = coupon
    @reward_on_renewal = reward_on_renewal

    send_to = @referrer_startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Your startup has unlocked SV.CO referral rewards!')
  end
end
