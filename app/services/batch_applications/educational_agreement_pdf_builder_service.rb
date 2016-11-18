module BatchApplications
  # Generates ready-to-sign Educational Agreement for a given Batch Application
  class EducationalAgreementPdfBuilderService
    def self.build(batch_application)
      new.build(batch_application)
    end

    def build(batch_application)
      pdf = CombinePDF.load('app/pdfs/educational_agreement/check_list.pdf')
      pdf << EducationalAgreement::PartOne.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/educational_agreement/part_two.pdf')
      pdf << EducationalAgreement::PartThree.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/educational_agreement/part_four.pdf')
      pdf << EducationalAgreement::PartFive.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/educational_agreement/part_six.pdf')
      pdf << EducationalAgreement::PartSeven.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/educational_agreement/part_eight.pdf')
      pdf << EducationalAgreement::PartNine.new(batch_application).build(combinable: true)
      pdf.info[:Title] = 'Educational Agreement'
      pdf
    end
  end
end
