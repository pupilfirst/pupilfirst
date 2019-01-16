module Founders
  class IdenticonLogoService
    def initialize(founder)
      @founder = founder
    end

    def base64_svg
      logo = Scarf::Identicon.new "#{@founder.name}.#{@founder.id}", options
      Base64.encode64(logo.to_blob)
    end

    private

    def options
      color.present? ? { color: color } : {}
    end

    def color
      possible_color = @founder.name.split.first.downcase
      possible_color.in?(colors) ? possible_color : nil
    end

    def colors
      YAML.load_file('app/services/startups/product_name_generator_service/startup_name_pool.yml')['color']
    end
  end
end
