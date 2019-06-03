module Home
  class PrivacyPresenter < ApplicationPresenter
    def initialize(view_context, privacy_policy)
      super(view_context)

      @privacy_policy = privacy_policy
    end

    def page_title
      current_school.blank? ? 'Pupilfirst' : current_school.name
    end

    def privacy_policy_html
      Kramdown::Document.new(@privacy_policy).to_html.html_safe
    end
  end
end
