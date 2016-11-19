module EducationalAgreement
  class PartThree < ApplicationPdf
    def initialize(batch_application)
      @batch_application = batch_application.decorate
      super()
    end

    def build(combinable: false)
      add_text
      combinable ? CombinePDF.parse(render) : self
    end

    private

    def add_text
      move_down 10
      text t('educational_agreement.part_three.header'), inline_format: true, align: :justify
      text t('educational_agreement.part_three.body', fee: fee, fee_in_words: fee_in_words), inline_format: true, indent_paragraphs: 30, align: :justify
    end

    def fee
      @batch_application.total_course_fee
    end

    def fee_in_words
      fee.humanize.titleize
    end
  end
end
