require 'keycloak'

module Devise
  module Strategies
    class Keycloak < Authenticatable
      def valid?
        request.path.match?(/^\/api/)
      end

      def authenticate!
        puts "Authenticate!"
        Rails.logger.debug("Auth header #{request.headers['Authorization']}")
        return fail if request.headers['Authorization'].blank?

        token = request.headers['Authorization'].split(' ').last
        user_info = Rails.configuration.keycloak_client.user_info(token)
        Rails.logger.debug("User info: #{user_info}")

        school = School.joins(:domains).where(domains: { fqdn: request.host }).first
        if user_info['active']
          school_admins = school.school_admins
          school_admin = school_admins.joins(:user)
            .where(users: { email: user_info['email'] })
            .limit(1).first
          user = school_admin.user
          user.update!(api_token_digest: digested_token(token, school))
          success!(school_admin.user)
        else
          fail!
        end
      end

      def store?
        false
      end

      def digested_token(token, school)
        Users::FindByApiTokenService.new(token, school).api_token_digest
      end
    end
  end
end
