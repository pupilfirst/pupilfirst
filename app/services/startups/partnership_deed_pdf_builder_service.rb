module Startups
  # Generates ready-to-sign Partnership Deed for a given Batch Application
  class PartnershipDeedPdfBuilderService
    def self.build(startup)
      new.build(startup)
    end

    def build(startup)
      pdf = CombinePDF.load('app/pdfs/partnership_deed/check_list.pdf')
      pdf << PartnershipDeed::PartnershipDeedPdf.new(startup).build(combinable: true)
      pdf.info[:Title] = 'Partnership Deed'
      pdf
    end
  end
end
