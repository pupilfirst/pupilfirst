module IncubationAgreement
  class PartFive < ApplicationPdf
    def initialize(startup)
      @startup = startup.decorate
      @team_lead = @startup.admin.decorate
      super()
    end

    def build(combinable: false)
      add_details
      combinable ? CombinePDF.parse(render) : self
    end

    private

    def add_details
      move_down 10
      text '8.2 <b>Address for Service</b>', inline_format: true
      add_sv_co_details
      add_startup_details
      add_founder_details
    end

    def add_sv_co_details
      move_down 10
      text t(
        'incubation_agreement.part_five.party_details',
        title: 'Service Provider',
        name: 'Sanjay Vijayakumar',
        designation: 'Chief Executive Officer',
        address: 'SV.CO DIGITAL PLATFORM PRIVATE LIMITED, Fourth Floor, Bhageeratha Square, Banerji Road,, Kacherippady, Ernakulam North, Cochin – 682018',
        email: 'help@sv.co'
      ), inline_format: true
    end

    def add_startup_details
      move_down 10
      text t(
        'incubation_agreement.part_five.party_details',
        title: 'Startup',
        name: @team_lead.name,
        designation: "#{@team_lead.roles.capitalize} Lead",
        address: @team_lead.communication_address.squish,
        email: @team_lead.email
      ), inline_format: true
    end

    def add_founder_details
      @startup.founders.each_with_index do |applicant, index|
        move_down 10
        text t(
          'incubation_agreement.part_five.party_details',
          title: "Founder #{index + 1}",
          name: applicant.name,
          designation: "#{applicant.roles.capitalize} Lead",
          address: applicant.communication_address.squish,
          email: applicant.email
        ), inline_format: true
      end
    end
  end
end
