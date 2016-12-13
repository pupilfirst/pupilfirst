module Startups
  class IdenticonLogoService
    def initialize(startup)
      @startup = startup
    end

    def base64_svg
      logo = Quilt::Identicon.new "#{@startup.product_name}.#{@startup.id}", color: 'red'
      Base64.encode64(logo.to_blob)
    end
  end
end
