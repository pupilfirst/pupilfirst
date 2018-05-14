module Founders
  # This is useful for injecting new founders into a startup. This can be used to easily add 'test users' into the SV.CO
  # startup, to allow demo-ing of the product.
  class InjectIntoStartupService
    def initialize(email, name, startup_slug)
      @email = email
      @name = name
      @startup = Startup.find_by!(slug: startup_slug)
    end

    def execute
      Founder.transaction do
        user = User.create!(email: @email)
        founder = Founder.create!(user: user, email: @email, name: @name, startup: @startup)
        Rails.logger.info("Founder with email address '#{@email}' was created (##{founder.id}), and added to Startup##{@startup.id}.")
      end
    end
  end
end
