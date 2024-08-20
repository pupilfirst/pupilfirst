module ConfigHelper
  def with_secret(secrets)
    original_secrets_values =
      secrets
        .keys
        .each_with_object({}) do |key, original_values|
          original_values[key] = Rails.application.secrets.send(key.to_s)
          Rails.application.secrets.send(key.to_s + "=", secrets[key])
        end

    yield

    original_secrets_values.each do |key, value|
      Rails.application.secrets.send(key.to_s + "=", value)
    end
  end
end
