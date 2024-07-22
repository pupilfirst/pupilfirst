module RecaptchaVerifiable
  extend ActiveSupport::Concern

  def recaptcha_success?(form, action:)
    if Rails.env.test?
      true
    else
      hostname = current_school.domains.primary.fqdn

      return true if Settings.recaptcha.disabled

      success =
        verify_recaptcha(
          model: form,
          action: action,
          minimum_score: 0.5,
          secret_key: Settings.recaptcha.v3_secret_key,
          hostname: hostname
        )

      checkbox_success =
        if success
          false
        else
          verify_recaptcha(
            model: form,
            secret_key: Settings.recaptcha.v2_secret_key,
            hostname: hostname
          )
        end

      success || checkbox_success
    end
  end
end
