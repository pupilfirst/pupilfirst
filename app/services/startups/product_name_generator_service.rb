module Startups
  class ProductNameGeneratorService
    COLORS = %w[blue brown crimson gold gray green indigo lilac magenta maroon orange pink purple red saffron silver turquoise violet yellow].freeze

    SCIENTISTS = %w[ali aryabhata ashtekar bhabha bell bohr bose copernicus curie darwin dhawan dirac edison einstein faraday fleming galilei
                    gauss halayudha hawking hertz hubble kalam kepler lovelace madhava maxwell mendeleev newton pasteur pauling planck raman
                    ramachandran ramakrishnan ramanujan sagan sarabhai tesla volta watt].freeze

    def fun_name
      "#{COLORS.sample} #{SCIENTISTS.sample}".titleize
    end
  end
end
