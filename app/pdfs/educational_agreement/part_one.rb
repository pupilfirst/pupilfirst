module EducationalAgreement
  class PartOne < ApplicationPdf
    def initialize(batch_application)
      @batch_application = batch_application.decorate
      @team_lead = @batch_application.team_lead.decorate
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
      text t('educational_agreement.title'), align: :center, inline_format: true, size: 13
      move_down 15
      text t(
        'educational_agreement.date_declaration',
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
      add_and_seperator
      add_startup_details
      add_founders
      add_parties_footer
    end

    def add_sv_co_details
      move_down 10
      text t('educational_agreement.sv_co_details'), inline_format: true
    end

    def add_and_seperator
      move_down 10
      text '<b>AND</b>', align: :center, inline_format: true
    end

    def add_startup_details
      move_down 10
      text t(
        'educational_agreement.startup_details',
        address: @team_lead.current_address.squish,
        team_lead_name: "#{@team_lead.mr_or_ms} #{@team_lead.name}",
        age: @team_lead.age,
        son_or_daughter: @team_lead.son_or_daughter,
        parent_name: @team_lead.parent_name
      ), inline_format: true
    end

    def add_founders
      batch_applicants.each_with_index { |applicant, index| add_founder_details(applicant, index) }
    end

    def add_founder_details(batch_applicant, index)
      applicant = batch_applicant.decorate
      move_down 10
      add_and_seperator
      text t(
        'educational_agreement.founder_details',
        name: applicant.name,
        age: applicant.age,
        son_or_daughter: applicant.son_or_daughter,
        parent_name: applicant.parent_name,
        address: applicant.current_address.squish,
        index: index + 1,
        party_number: ORDINALIZE[index + 2]
      ), inline_format: true
    end

    def add_parties_footer
      move_down 10
      text t('educational_agreement.parties_footer', founders_list: founders_list), inline_format: true
    end

    def founders_list
      list = []
      batch_applicants.each_with_index { |_applicant, index| list << "Founder #{index + 1}" }
      list.to_sentence
    end

    def batch_applicants
      @batch_applicants ||= @batch_application.batch_applicants
    end

    ORDINALIZE = %w(First Second Third Fourth Fifth Sixth Seventh Eighth Ninth Tenth Eleventh Twelfth).freeze
  end
end
