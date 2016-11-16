class ApplicationPdf < Prawn::Document
  def initialize
    super(margin: 70, page_size: 'A4')
    default_leading 10
    font 'Times-Roman'
  end

  protected

  def t(*args)
    I18n.t(*args)
  end
end
