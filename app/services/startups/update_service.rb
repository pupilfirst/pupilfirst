module Startups
  class UpdateService
    def initialize(startup)
      @startup = startup
    end

    def update(params)
      product_name_changed = params[:product_name] != @startup.product_name

      return false unless @startup.update(params)

      # Update their profile name on Slack if the product name has changed.
      if product_name_changed
        @startup.founders.each { |founder| Founders::UpdateSlackNameJob.perform_later(founder) }
      end

      true
    end
  end
end
