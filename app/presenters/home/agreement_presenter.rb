module Home
  class AgreementPresenter < ApplicationPresenter
    def initialize(view_context, agreement)
      super(view_context)

      @agreement = agreement
    end

    def page_title
      current_school.name
    end

    def agreement_html
      Kramdown::Document.new(@agreement).to_html.html_safe
    end
  end
end
