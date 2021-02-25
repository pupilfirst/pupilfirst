module Keycloak
  class SetupStudentAccount
    def initialize(keycloak_client = Rails.configuration.keycloak_client)
      @keycloak_client = keycloak_client
    end

    def call(actor_id:, **_)
      student = User.find(actor_id)
      create_keycloak_user(student.email, student.name)
    end

    private

    def create_keycloak_user(email, name)
      first_name, *names = name.split(' ')
      last_name = names.join(' ')
      @keycloak_client.create_user(email, first_name, last_name)
    end
  end
end
