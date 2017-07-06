module Startups
  class ProductNameGeneratorService
    def fun_name
      "#{pool['color'].sample} #{pool['scientist'].sample}".titleize
    end

    def colors
      pool['color']
    end

    private

    def pool
      @pool ||= YAML.load_file('app/services/startups/product_name_generator_service/startup_name_pool.yml')
    end
  end
end
