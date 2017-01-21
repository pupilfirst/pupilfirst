class AdminUserMailer < ApplicationMailer
  def batch_sweep(admin_email, target_application_round, counts)
    @counts = counts
    @target_application_round = target_application_round
    mail(to: admin_email, subject: 'Batch Sweep Job Complete!')
  end
end
