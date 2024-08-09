module ConfigHelper
  def with_env(variables)
    original_env_vars =
      variables
        .keys
        .each_with_object({}) do |key, original_variables|
          original_variables[key] = ENV[key.to_s]
          ENV[key.to_s] = variables[key]
          original_variables
        end

    yield

    original_env_vars.each { |key, value| ENV[key.to_s] = value }
  end

  def with_secret(secrets)
    original_secrets_values =
      secrets
        .keys
        .each_with_object({}) do |key, original_values|
          original_values[key] = Settings.send(key.to_s)
          Settings.send(key.to_s + '=', secrets[key])
        end

    yield

    original_secrets_values.each do |key, value|
      Settings.send(key.to_s + '=', value)
    end
  end
end
