module Schools
  class Configuration
    include ActiveModel::Model
    include ActiveModel::Validations

    def initialize(school)
      @school = school
    end

    # discord: {
    #   server_id: string,
    #   bot_token: string,
    #   default_role_ids: [string]
    # }
    def discord
      @school.configuration['discord']
    end

    # disable_primary_domain_redirection: boolean
    def disable_primary_domain_redirection
      @school.configuration['disable_primary_domain_redirection']
    end

    # email_sender_signature: {
    #   name: string,
    #   email: string,
    #   confirmed_at: string
    # }
    def email_sender_signature
      @school.configuration['email_sender_signature']
    end

    # vimeo: {
    #   account_type: string,
    #   access_token: string,
    # }
    def vimeo
      @school.configuration['vimeo']
    end

    # delete_inactive_users_after: integer
    def delete_inactive_users_after
      @school.configuration['delete_inactive_users_after']
    end
  end
end
