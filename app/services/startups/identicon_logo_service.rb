module Startups
  class IdenticonLogoService
    def initialize(startup)
      @startup = startup
    end

    def base64_svg
      logo = Scarf::Identicon.new "#{@startup.name}.#{@startup.id}", options
      Base64.encode64(logo.to_blob)
    end

    private

    def options
      color.present? ? { color: color } : {}
    end

    def color
      possible_color = @startup.name.split.first.downcase
      possible_color.in?(NameGeneratorService.new.colors) ? possible_color : nil
    end
  end
end
