class PartnershipDeedPdf < Prawn::Document
  def initialize(batch_application)
    @batch_application = batch_application.decorate
    super()
    add_header
    add_partners
  end

  private

  def add_header
    move_down 300
    font 'Times-Roman', style: :bold
    text '<u>DEED OF PARTNERSHIP</u>', align: :center, inline_format: true
  end

  def add_partners
    move_down 10
    font 'Times-Roman', style: :normal
    text "This Deed of Partnership (“<b>Deed</b>”) is made on this #{Date.today.day.ordinalize} day of #{Date.today.strftime('%B %Y')} by and between:", inline_format: true

    add_partner_details
  end

  def add_partner_details
    move_down 5
    @batch_application.batch_applicants.each_with_index do |batch_applicant, index|
      @applicant = batch_applicant.decorate
      @index = index

      text partner_description, inline_format: true, indent_paragraphs: 30
      move_down 5
    end
  end

  def partner_description
    "<b>#{@index + 1}.</b> #{partner_basic_info}, #{partner_address_and_id} #{common_text_for_partner}"
  end

  def partner_basic_info
    "#{@applicant.name}, s/d/o of #{@applicant.guardian_name}, aged about #{@applicant.age}"
  end

  def partner_address_and_id
    "residing at #{@applicant.current_address} and having Aadhaar Card / Driving License / Passport No. #{@applicant.id_proof_number}"
  end

  def common_text_for_partner
    "(hereinafter referred to as the “#{(@index + 1).ordinalize} Partner” which expression shall, unless it is repugnant to the context, mean and include his/her legal heirs, successors, administrators and assigns or anyone claiming through or under him/her);"
  end
end
