module EducationalAgreement
  class PartNine < ApplicationPdf
    def initialize(batch_application)
      @batch_application = batch_application.decorate
      super()
    end

    def build(combinable: false)
      add_signatures
      combinable ? CombinePDF.parse(render) : self
    end

    private

    def add_signatures
      move_down 10
      text t('educational_agreement.part_nine.header'), inline_format: true
      column_box([0, cursor], columns: 2, width: bounds.width) do
        move_down 15
        text t('educational_agreement.part_nine.sign_on_behalf',
          name: 'SV.CO DIGITAL PLATFORM PRIVATE LIMITED',
          designation: 'Service Provider',
          by_name: 'Sanjay Vijayakumar',
          title: 'Chief Executive Officer')
        move_down 15
        text t('educational_agreement.part_nine.sign_on_behalf',
          name: '__________________________________',
          designation: 'Startup',
          by_name: @batch_application.team_lead.name,
          title: "#{@batch_application.team_lead.role.capitalize} Lead")
        @batch_application.batch_applicants.each_with_index { |applicant, index| add_founder_signature(applicant, index) }
      end
    end

    def add_founder_signature(applicant, index)
      move_down 15
      text t(
        'educational_agreement.part_nine.founder_sign',
        name: applicant.name,
        index: index + 1
      )
    end
  end
end
