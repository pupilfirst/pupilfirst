module RecaptchaVerifiable
  extend ActiveSupport::Concern

  def recaptcha_success?(form, action:)
    if Rails.env.test?
      true
    else
      hostname = current_school.domains.primary.fqdn

      success =
        verify_recaptcha(
          model: form,
          action: action,
          minimum_score: 0.5,
          secret_key: ENV['RECAPTCHA_V3_SECRET_KEY'],
          hostname: hostname
        )

      checkbox_success =
        if success
          false
        else
          verify_recaptcha(
            model: form,
            secret_key: ENV['RECAPTCHA_V2_SECRET_KEY'],
            hostname: hostname
          )
        end

      success || checkbox_success
    end
  end
end
