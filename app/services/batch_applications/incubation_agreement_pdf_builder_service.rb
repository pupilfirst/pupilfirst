module BatchApplications
  # Generates ready-to-sign Incubation Agreement for a given Batch Application
  class IncubationAgreementPdfBuilderService
    def self.build(batch_application)
      new.build(batch_application)
    end

    def build(batch_application)
      pdf = CombinePDF.load('app/pdfs/incubation_agreement/check_list.pdf')
      pdf << IncubationAgreement::PartOne.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_two.pdf')
      pdf << IncubationAgreement::PartThree.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_four.pdf')
      pdf << IncubationAgreement::PartFive.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_six.pdf')
      pdf << IncubationAgreement::PartSeven.new(batch_application).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_eight.pdf')
      pdf << IncubationAgreement::PartNine.new(batch_application).build(combinable: true)
      pdf.info[:Title] = 'Incubation Agreement'
      pdf
    end
  end
end
