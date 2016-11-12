class PartnershipDeedPdf < Prawn::Document
  def initialize(batch_application)
    @batch_application = batch_application.decorate
    super(margin: 70)
    default_leading 5
  end

  def build!
    add_header
    add_partners
    add_whereas_clause
    add_agreement_clauses
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
    text t('partnership_deed.whereas.a'), inline_format: true
    3.times do
      move_down 15
      stroke_horizontal_rule
    end
    move_down 10
    text t('partnership_deed.whereas.b'), inline_format: true
  end

  def add_agreement_clauses
    move_down 10
    font 'Times-Roman', style: :bold
    text 'NOW THEREFORE, IN CONSIDERATION OF THE MUTUAL PROMISES AND COVENANTS CONTAINED HEREIN, THE PARTNERS HEREBY AGREE AS FOLLOWS:'

    add_definitions
    add_commencement
    add_firm_details
    add_partnership_business
    add_partner_clauses
    add_capital_contribution
  end

  def add_definitions
    move_down 10
    font 'Times-Roman', style: :normal
    text t('partnership_deed.s1.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s1.c1')
    move_down 15
    stroke_horizontal_rule
    move_down 10
    text t('partnership_deed.s1.c2')
    text t('partnership_deed.s1.c3')
  end

  def add_commencement
    move_down 10
    text t('partnership_deed.s2.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s2.text')
  end

  def add_firm_details
    move_down 10
    text t('partnership_deed.s3.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s3.c1')
    text t('partnership_deed.s3.c2')
  end

  def add_partnership_business
    move_down 10
    text t('partnership_deed.s4.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s4.C')
    3.times do
      move_down 15
      stroke_horizontal_rule
    end
    move_down 10
    text t('partnership_deed.s4.c1'), inline_format: true
    text t('partnership_deed.s4.c2')
  end

  def add_partner_clauses
    move_down 10
    text t('partnership_deed.s5.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s5.c1')
    add_s5_c2
    add_s5_c3
  end

  def add_s5_c2
    move_down 10
    text t('partnership_deed.s5.c2.heading')
    move_down 10
    text t('partnership_deed.s5.c2.c1'), indent_paragraphs: 30
    text t('partnership_deed.s5.c2.c2'), indent_paragraphs: 30
    text t('partnership_deed.s5.c2.c3.text'), indent_paragraphs: 30
    text t('partnership_deed.s5.c2.c3.c1'), indent_paragraphs: 60
    text t('partnership_deed.s5.c2.c3.c2'), indent_paragraphs: 60
  end

  def add_s5_c3
    move_down 10
    text t('partnership_deed.s5.c3.heading')
    move_down 10
    text t('partnership_deed.s5.c3.c1'), indent_paragraphs: 30
    text t('partnership_deed.s5.c3.c2'), indent_paragraphs: 30
    text t('partnership_deed.s5.c3.c3'), indent_paragraphs: 30
    text t('partnership_deed.s5.c3.c4'), indent_paragraphs: 30
    text t('partnership_deed.s5.c3.c5'), indent_paragraphs: 30
  end

  def add_capital_contribution
    move_down 10
    text t('partnership_deed.s6.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s6.c1')
    add_capital_contribution_table
    move_down 10
    text t('partnership_deed.s6.c2')
    text t('partnership_deed.s6.c3')
    text t('partnership_deed.s6.c4')
    text t('partnership_deed.s6.c5')
    text t('partnership_deed.s6.c6')
  end

  def add_capital_contribution_table
    move_down 10
    table_rows = [['<b>Partner</b>', '<b>Amount</b>']]
    @batch_application.batch_applicants.each_with_index do |_batch_applicant, index|
      table_rows << ["#{(index + 1).ordinalize} Partner", '']
    end

    table table_rows, position: :center, width: 300, cell_style: { inline_format: true }
  end

  def t(*args)
    I18n.t(*args)
  end
end
