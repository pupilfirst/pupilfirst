module Schools
  class UpdateSubdomainService
    def initialize(school)
      @school = school
    end

    def update(subdomain)
      # Delete the existing subdomain.
      #
      # then
      #
      # Register the new subdomain with Schools::RegisterSubdomainService.new
    end

    private

    # Deletion route.
    def api
      @api ||= Cloudflare::ApiService.new('zones/:zone_identifier/dns_records/:identifier')
    end
  end
end
