require 'keycloak'

module Devise
  module Strategies
    class Keycloak < Base
      def authenticate!
        return fail if request.headers['Authorization'].blank?

        token = request.headers['Authorization'].split(' ').last
        user_info = keycloak_client.user_info(token)
        course = Course.find(request.params['course_id'])

        if user_info['active']
          school_admins = course.school.school_admins
          user = school_admins.joins(:user)
            .where(users: { email: user_info['email'] })
            .limit(1).first
          success!(user)
        else
          fail
        end
      end

      def keycloak_client
        @keycloak_client ||= ::Keycloak::Client.new
      end
    end
  end
end
