require 'keycloak'

module Devise
  module Strategies
    class Keycloak < Base
      def authenticate!
        return fail if request.headers['Authorization'].blank?

        token = request.headers['Authorization'].split(' ').last
        user_info = keycloak_client.user_info(token)

        school = School.joins(:domains).where(domains: { fqdn: request.host }).first
        if user_info['active']
          school_admins = school.school_admins
          school_admin = school_admins.joins(:user)
            .where(users: { email: user_info['email'] })
            .limit(1).first
          success!(school_admin.user)
        else
          fail!
        end
      end

      def store?
        false
      end

      def keycloak_client
        @keycloak_client ||= ::Keycloak::Client.new
      end
    end
  end
end
