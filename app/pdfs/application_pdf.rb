class ApplicationPdf < Prawn::Document
  def initialize
    super(margin: 70)
    default_leading 5
    font 'Times-Roman'
  end

  protected

  def t(*args)
    I18n.t(*args)
  end
end
