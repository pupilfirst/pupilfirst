module IncubationAgreement
  class PartSeven < ApplicationPdf
    def initialize(startup)
      @startup = startup.decorate
      super()
    end

    def build(combinable: false)
      add_details
      combinable ? CombinePDF.parse(render) : self
    end

    private

    def add_details
      move_down 10
      text '<b>SCHEDULE B</b>', inline_format: true, align: :center
      text '<b>Details of Founders & Founding Team</b>', inline_format: true, align: :center
      add_founder_details
    end

    def add_founder_details
      @startup.founders.each_with_index do |founder, index|
        founder = founder.decorate
        move_down 10
        text t(
          'incubation_agreement.part_seven.founder_details',
          index: index + 1,
          name: founder.name,
          designation: "#{founder.roles.capitalize} Lead",
          son_or_daughter: founder.son_or_daughter,
          parent_name: founder.parent_name,
          age: founder.age,
          id_proof_type: founder.id_proof_type,
          id_proof_number: founder.id_proof_number,
          current_address: founder.communication_address.squish,
          permanent_address: founder.permanent_address.squish,
          phone: founder.phone
        )
      end
    end
  end
end
