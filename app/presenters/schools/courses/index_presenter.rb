module Schools
  module Courses
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context)
        super(view_context)
      end

      def react_props
        {
          authenticityToken: view.form_authenticity_token
        }
      end
    end
  end
end
