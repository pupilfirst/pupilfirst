module ActiveAdmin
  class DashboardPresenter
    attr_reader :intercom

    def initialize
      @intercom = IntercomClient.new
    end

    INTERCOM_METHODS = [:unassigned_conversations_count, :assigned_conversations_count, :open_conversations_count,
                        :closed_conversations_count, :new_users_count, :active_users_count].freeze

    INTERCOM_METHODS.each do |method_name|
      define_method method_name do
        begin
          intercom.public_send(method_name)
        rescue Exceptions::IntercomError
          'Error'
        end
      end
    end
  end
end
