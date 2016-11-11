# rubocop:disable Metrics/LineLength
class PartnershipDeedPdf < Prawn::Document
  def initialize(batch_application)
    @batch_application = batch_application.decorate
    super(margin: 70)
    default_leading 5
    add_header
    add_partners
    add_whereas_clause
    add_agreement_clause
  end

  private

  def add_header
    move_down 300
    font 'Times-Roman', style: :bold
    text '<u>DEED OF PARTNERSHIP</u>', align: :center, inline_format: true, size: 15
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

    text '(The above parties shall be hereinafter collectively referred to as the “Partners” and individually as “Partner”).'
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

  def add_whereas_clause
    move_down 10
    font 'Times-Roman', style: :bold
    text 'WHEREAS:'
    move_down 5
    font 'Times-Roman', style: :normal
    text '<b>A.</b> The Partners have decided to work together as a partnership firm to develop a commercially viable business involving', inline_format: true
    3.times do
      move_down 15
      stroke_horizontal_rule
    end
    move_down 10
    text '<b>B.</b> The Partners have entered into this Deed of Partnership to form a partnership firm in accordance with this Deed and for laying out the rights and duties of the Partners and the terms and conditions to regulate and govern the relationship between Partners and the Firm (as defined hereinafter).', inline_format: true
  end

  def add_agreement_clause
    move_down 10
    font 'Times-Roman', style: :bold
    text 'NOW THEREFORE, IN CONSIDERATION OF THE MUTUAL PROMISES AND COVENANTS CONTAINED HEREIN, THE PARTNERS HEREBY AGREE AS FOLLOWS:'

    add_definitions
    add_commencement
    add_firm_details
    add_partnership_business
    add_partner_clauses
  end

  def add_definitions
    move_down 10
    font 'Times-Roman', style: :normal
    text '<b>1. Definition</b>', inline_format: true
    move_down 10
    text '1.1 “Firm” means the partnership firm hereby formed by the Partners under this Deed in the name and style:'
    move_down 15
    stroke_horizontal_rule
    move_down 10
    text '1.2 “Partnership Business” shall have the meaning assigned to it under Clause 4.1 herein.'
    text '1.3 “Sharing Ratio” means the inter se proportion of sharing in profits and losses amongst the Partners in the ratio set out in Clause 7.1.'
  end

  def add_commencement
    move_down 10
    text '<b>2. Commencement of the Partnership Business</b>', inline_format: true
    move_down 10
    text 'The Partners agree that this Deed shall be effective from the date of execution of this Deed, as first mentioned hereinabove.'
  end

  def add_firm_details
    move_down 10
    text '<b>3. Name and Address of the Firm</b>', inline_format: true
    move_down 10
    text '3.1 The Partnership Business shall be conducted by the Partners through a firm constituted under the name and style of ______________________'
    text '3.2 The Firm shall have its office at ______________________ and /or at such other place or places, as is agreed between the Partners from time to time.'
  end

  def add_partnership_business
    move_down 10
    text '<b>4. Partnership Business</b>', inline_format: true
    move_down 10
    text 'C. The Firm has been established for the purpose of developing and operating a commercially viable business involving'
    3.times do
      move_down 15
      stroke_horizontal_rule
    end
    move_down 10
    text '4.1 (“<b>Partnership Business</b>”). The Firm may also conduct such other activities, whether or not for profit, as mutually agreed to by all Partners all of which shall form part of the Partnership Business.', inline_format: true
    text '4.2 The duration of the partnership shall be "At Will ".'
  end

  def add_partner_clauses
    move_down 10
    text '<b>5. Partners</b>', inline_format: true
    move_down 10
    text '5.1 No individual or body corporate may be introduced as a new partner without the consent of the existing Partners. Such incoming partner shall give his/her prior consent to act as Partner of the Firm and shall execute a deed of reconstitution agreeing to abide by the terms of the Reconstitution Deed so executed. On execution of the Reconstitution Deed, such person shall become a partner and be entitled to the rights and have such duties as set forth in such Reconstitution Deed.'
    text '5.2 Rights of the Partners'
    move_down 10
    text '5.2.1 All the Partners hereto shall have the rights, title and interest in all the assets and properties in the Firm in the proportion of their Sharing Ratio.', indent_paragraphs: 30
    text '5.2.2 Each of the Partners would be entitled to withdraw reasonable amounts from the Firm’s account from time to time as may be mutually agreed upon between the Partners.', indent_paragraphs: 30
    text '5.2.3 All agreements, contracts, memorandums of understanding, deeds and all such instruments to which the Firm is a party, may be signed either:', indent_paragraphs: 30
    text '5.2.3.1 by the First Partner and Second Partner, on behalf of the Firm and all Partners; or', indent_paragraphs: 60
    text '5.2.3.2 Jointly by all Partners, on behalf of the Firm, which execution shall be binding and effective  on the Firm and all Partners.', indent_paragraphs: 60
    text '5.3 Duties of Partners'
    move_down 10
    text '5.3.1 Every Partner shall account to the Firm for any benefit derived by her without the consent of the Firm from any transaction concerning the Firm, or from any use by her of the property, name or any business connection of the Firm.', indent_paragraphs: 30
    text '5.3.2 Every Partner shall indemnify the Firm and the other existing partner(s) for any loss caused to it by her conduct of the business on behalf of the Firm.', indent_paragraphs: 30
    text '5.3.3 Each Partner shall render true accounts and full information of all things affecting the Firm to any Partner or her legal representatives.', indent_paragraphs: 30
    text '5.3.4 Each of the Partners shall make all endeavors and devote their full working time and efforts for the fulfillment of the objectives of the Firm and for conduct of the Partnership Business.', indent_paragraphs: 30
    text '5.3.5 All intellectual property rights created and developed by each Partner in the conduct, development and operation of the Partnership Business shall be the property of the Firm and each Partner hereby assigns all such copyrights and other intellectual property rights to the Firm.', indent_paragraphs: 30
  end
end
# rubocop:enable Metrics/LineLength
