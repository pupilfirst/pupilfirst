module Startups
  # Generates ready-to-sign Incubation Agreement for a given Batch Application
  class IncubationAgreementPdfBuilderService
    def self.build(startup)
      new.build(startup)
    end

    def build(startup)
      pdf = CombinePDF.load('app/pdfs/incubation_agreement/check_list.pdf')
      pdf << IncubationAgreement::PartOne.new(startup).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_two.pdf')
      pdf << IncubationAgreement::PartThree.new(startup).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_four.pdf')
      pdf << IncubationAgreement::PartFive.new(startup).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_six.pdf')
      pdf << IncubationAgreement::PartSeven.new(startup).build(combinable: true)
      pdf << CombinePDF.load('app/pdfs/incubation_agreement/part_eight.pdf')
      pdf << IncubationAgreement::PartNine.new(startup).build(combinable: true)
      pdf.info[:Title] = 'Incubation Agreement'
      pdf
    end
  end
end
