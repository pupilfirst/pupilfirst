class AdminUserMailer < ApplicationMailer
  def batch_sweep(admin_email, target_batch_number, counts)
    @counts = counts
    @target_batch_number = target_batch_number
    mail(to: admin_email, subject: 'Batch Sweep Job Complete!')
  end
end
