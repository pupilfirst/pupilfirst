module ConfigHelper
  def with_secret(secrets)
    original_secrets_values =
      secrets
        .keys
        .each_with_object({}) do |key, original_values|
          original_values[key] = Settings.send(key.to_s)
          Settings.send(key.to_s + "=", secrets[key])
        end

    yield

    original_secrets_values.each do |key, value|
      Settings.send(key.to_s + "=", value)
    end
  end
end
