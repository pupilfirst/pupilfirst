module Startups
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, startup)
      @startup = startup
      super(view_context)
    end

    def identicon_logo
      base64_logo = Startups::IdenticonLogoService.new(@startup).base64_svg
      view.image_tag("data:image/svg+xml;base64,#{base64_logo}", class: 'startup-logo')
    end
  end
end
