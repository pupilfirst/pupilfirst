module EducationalAgreement
  class PartSeven < ApplicationPdf
    def initialize(batch_application)
      @batch_application = batch_application.decorate
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
      @batch_application.batch_applicants.each_with_index do |batch_applicant, index|
        applicant = batch_applicant.decorate
        move_down 10
        text t(
          'educational_agreement.part_seven.founder_details',
          index: index + 1,
          name: applicant.name,
          designation: "#{applicant.role.capitalize} Lead",
          son_or_daughter: applicant.son_or_daughter,
          parent_name: applicant.parent_name,
          age: applicant.age,
          id_proof_type: applicant.id_proof_type,
          id_proof_number: applicant.id_proof_number,
          current_address: applicant.current_address.squish,
          permanent_address: applicant.permanent_address.squish,
          phone: applicant.phone
        )
      end
    end
  end
end
