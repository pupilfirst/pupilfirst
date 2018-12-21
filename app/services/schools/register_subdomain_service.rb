module Schools
  # Register the stored subdomain value for a school at Cloudflare.
  class RegisterSubdomainService
    def initialize(school)
      @school = school
    end

    def execute
      # POST to 'api' here.
    end

    private

    # Addition route.
    def api
      @api ||= Cloudflare::ApiService.new('zones/:zone_identifier/dns_records')
    end
  end
end
