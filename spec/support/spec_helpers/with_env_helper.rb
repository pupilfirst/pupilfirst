module WithEnvHelper
  def with_env(variables)
    original_env_vars = variables.keys.each_with_object({}) do |key, original_variables|
      original_variables[key] = ENV[key.to_s]
      ENV[key.to_s] = variables[key]
      original_variables
    end

    yield

    original_env_vars.each do |key, value|
      ENV[key.to_s] = value
    end
  end
end
