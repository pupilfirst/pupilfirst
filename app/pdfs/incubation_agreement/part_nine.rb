module IncubationAgreement
  class PartNine < ApplicationPdf
    def initialize(startup)
      @startup = startup.decorate
      super()
    end

    def build(combinable: false)
      add_signatures
      combinable ? CombinePDF.parse(render) : self
    end

    private

    def add_signatures
      move_down 10
      text t('incubation_agreement.part_nine.header'), inline_format: true
      column_box([0, cursor], columns: 2, width: bounds.width) do
        move_down 15
        text t('incubation_agreement.part_nine.sign_on_behalf',
          name: 'SV.CO DIGITAL PLATFORM PRIVATE LIMITED',
          designation: 'Service Provider',
          by_name: 'Sanjay Vijayakumar',
          title: 'Chief Executive Officer')
        move_down 15
        text t('incubation_agreement.part_nine.sign_on_behalf',
          name: '__________________________________',
          designation: 'Startup',
          by_name: @startup.admin.name,
          title: 'Team Lead')
        @startup.founders.each_with_index { |founder, index| add_founder_signature(founder, index) }
      end
    end

    def add_founder_signature(founder, index)
      move_down 15
      text t(
        'incubation_agreement.part_nine.founder_sign',
        name: founder.name,
        index: index + 1
      )
    end
  end
end
