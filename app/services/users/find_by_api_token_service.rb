module Users
  class FindByApiTokenService
    def initialize(api_token, school)
      @api_token = api_token
      @school = school
    end

    def find
      @school.users.find_by(api_token_digest: api_token_digest)
    end

    def api_token_digest
      Digest::SHA2.base64digest(@api_token)
    end
  end
end
