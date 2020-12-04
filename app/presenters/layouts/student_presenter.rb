module Layouts
  class StudentPresenter < ::ApplicationPresenter
    def initialize(view_context, current_user)
      @current_user = current_user
      super(view_context)
    end

    def head_google_tag_manager
      return unless Rails.env.production?
      ENV['GTM_HEAD']
    end

    def body_google_tag_manager
      return unless Rails.env.production?
      ENV['GTM_BODY']
    end

    def current_user_email
      return unless Rails.env.production?
      return if @current_user.nil?
      @current_user.email
    end
  end
end
