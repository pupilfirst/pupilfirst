module IncubationAgreement
  class PartOne < ApplicationPdf
    def initialize(startup)
      @startup = startup.decorate
      @team_lead = @startup.team_lead.decorate
      super()
    end

    def build(combinable: false)
      move_down 300
      add_title_and_date
      add_agreement_parties
      combinable ? CombinePDF.parse(render) : self
    end

    private

    def add_title_and_date
      move_down 10
      text t('incubation_agreement.title'), align: :center, inline_format: true, size: 13
      move_down 15
      text t(
        'incubation_agreement.date_declaration',
        day: Date.today.day.ordinalize,
        month: Date.today.strftime('%B %Y'),
        effective_date: effective_date
      ), inline_format: true
    end

    def effective_date
      Date.today.strftime('%B %d, %Y')
    end

    def add_agreement_parties
      move_down 10
      text '<b>BETWEEN:</b>', align: :center, inline_format: true
      add_sv_co_details
      start_new_page
      add_and_seperator
      add_startup_details
      add_founders
      add_parties_footer
    end

    def add_sv_co_details
      move_down 10
      text t('incubation_agreement.sv_co_details'), inline_format: true
    end

    def add_and_seperator
      move_down 10
      text '<b>AND</b>', align: :center, inline_format: true
    end

    def add_startup_details
      move_down 10
      text t(
        'incubation_agreement.startup_details',
        address: @team_lead.communication_address.squish,
        team_lead_name: "#{@team_lead.mr_or_ms} #{@team_lead.name}",
        age: @team_lead.age,
        son_or_daughter: @team_lead.son_or_daughter,
        parent_name: @team_lead.parent_name
      ), inline_format: true
    end

    def add_founders
      founders.each_with_index { |founder, index| add_founder_details(founder, index) }
    end

    def add_founder_details(founder, index)
      founder = founder.decorate
      move_down 10
      add_and_seperator
      text t(
        'incubation_agreement.founder_details',
        name: founder.name,
        age: founder.age,
        son_or_daughter: founder.son_or_daughter,
        parent_name: founder.parent_name,
        address: founder.communication_address.squish,
        index: index + 1,
        party_number: ORDINALIZE[index + 2]
      ), inline_format: true
    end

    def add_parties_footer
      move_down 10
      text t('incubation_agreement.parties_footer', founders_list: founders_list), inline_format: true
    end

    def founders_list
      list = []
      founders.each_with_index { |_founder, index| list << "Founder #{index + 1}" }
      list.to_sentence
    end

    def founders
      @founders ||= @startup.founders
    end

    ORDINALIZE = %w[First Second Third Fourth Fifth Sixth Seventh Eighth Ninth Tenth Eleventh Twelfth].freeze
  end
end
