module BatchApplications
  # Generates ready-to-sign Educational Agreement for a given Batch Application
  class EducationalAgreementPdfBuilderService
    def self.build(batch_application)
      new.build(batch_application)
    end

    def build(batch_application)
      pdf = EducationalAgreement::PartOne.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/educational_agreement/part_two.pdf')
    end
  end
end
