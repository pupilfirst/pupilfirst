module BatchApplications
  # Generates ready-to-sign Partnership Deed for a given Batch Application
  class PartnershipDeedPdfBuilderService
    def self.build(batch_application)
      new.build(batch_application)
    end

    def build(batch_application)
      pdf = CombinePDF.load('app/pdfs/partnership_deed/check_list.pdf')
      pdf << PartnershipDeed::PartnershipDeedPdf.new(batch_application).build(combinable: true)
      pdf.info[:Title] = 'Partnership Deed'
      pdf
    end
  end
end
