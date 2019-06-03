module Home
  class TermsPresenter < ApplicationPresenter
    def initialize(view_context, terms_of_use)
      super(view_context)

      @terms_of_use = terms_of_use
    end

    def page_title
      current_school.blank? ? 'Pupilfirst' : current_school.name
    end

    def terms_of_use_html
      Kramdown::Document.new(@terms_of_use).to_html.html_safe
    end
  end
end
