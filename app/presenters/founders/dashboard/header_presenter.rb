module Founders
  module Dashboard
    class HeaderPresenter < ApplicationPresenter
      def identicon_logo
        base64_logo = Startups::IdenticonLogoService.new(view.current_startup).base64_svg
        view.image_tag("data:image/svg+xml;base64,#{base64_logo}", class: 'founder-dashboard-header__startup-logo')
      end
    end
  end
end
