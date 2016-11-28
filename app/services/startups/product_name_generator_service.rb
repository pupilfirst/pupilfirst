module Startups
  class ProductNameGeneratorService
    COLORS = %w(blue brown crimson gold gray green indigo lilac magenta maroon orange pink purple red saffron silver turquoise violet yellow).freeze

    SCIENTISTS = %w(bell bohr copernicus curie darwin dirac edison einstein faraday fleming galilei gauss hawking hertz hubble kalam kepler lovelace maxwell mendeleev newton pasteur pauling planck raman ramanujan sagan sarabhai tesla volta watt).freeze

    def fun_name
      "#{COLORS.sample} #{SCIENTISTS.sample}".titleize
    end
  end
end
