class PartnershipDeedPdf < Prawn::Document
  def initialize(batch_application)
    @batch_application = batch_application.decorate
    super(margin: 70)
    default_leading 5
    font 'Times-Roman'
  end

  def build!
    add_title
    declare_partners
    add_whereas_clause
    add_agreement_clauses
    add_signatures
  end

  private

  def add_title
    move_down 300
    text '<b><u>DEED OF PARTNERSHIP</u></b>', align: :center, inline_format: true, size: 15
  end

  def declare_partners
    move_down 10
    text t('partnership_deed.declaration.header', day: Date.today.day.ordinalize, month: Date.today.strftime('%B %Y')), inline_format: true
    add_partner_details
    text t('partnership_deed.declaration.footer')
  end

  def add_partner_details
    move_down 5
    @batch_application.batch_applicants.each_with_index { |applicant, index| add_founder_to_partners(applicant, index) }
  end

  def add_founder_to_partners(batch_applicant, index)
    @applicant = batch_applicant.decorate
    @index = index + 1
    text partner_description, inline_format: true, indent_paragraphs: 30
    move_down 5
  end

  def partner_description
    t(
      'partnership_deed.declaration.partner_description',
      index: @index,
      ordinalized_index: @index.ordinalize,
      name: @applicant.name,
      guardian_name: @applicant.guardian_name,
      age: @applicant.age,
      current_address: @applicant.current_address,
      id_proof_number: @applicant.id_proof_number
    )
  end

  def add_whereas_clause
    move_down 10
    text '<b>WHEREAS:</b>', inline_format: true
    move_down 5
    text t('partnership_deed.whereas.a'), inline_format: true
    3.times do
      move_down 15
      stroke_horizontal_rule
    end
    move_down 10
    text t('partnership_deed.whereas.b'), inline_format: true
  end

  # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
  def add_agreement_clauses
    move_down 10
    text t('partnership_deed.agreements_header'), inline_format: true

    # Section 1: Definitions
    move_down 10
    font 'Times-Roman', style: :normal
    text t('partnership_deed.s1.part_1'), inline_format: true
    move_down 15
    stroke_horizontal_rule
    move_down 10
    text t('partnership_deed.s1.part_2')

    # Section 2: Commencement of the Partnership Business
    move_down 10
    text t('partnership_deed.s2'), inline_format: true

    # Section 3: Name and Address of the Firm
    move_down 10
    text t('partnership_deed.s3'), inline_format: true

    # Section 4: Partnership Business
    move_down 10
    text t('partnership_deed.s4.part_1'), inline_format: true
    3.times do
      move_down 15
      stroke_horizontal_rule
    end
    move_down 10
    text t('partnership_deed.s4.part_2'), inline_format: true

    # Section 5: Partners
    move_down 10
    text t('partnership_deed.s5.part_1'), inline_format: true
    text t('partnership_deed.s5.part_2'), indent_paragraphs: 30
    text t('partnership_deed.s5.part_3'), indent_paragraphs: 60
    text t('partnership_deed.s5.part_4_heading')
    text t('partnership_deed.s5.part_4'), indent_paragraphs: 30

    # Section 6: Capital Contribution
    move_down 10
    text t('partnership_deed.s6.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s6.c1')
    add_capital_contribution_table
    move_down 10
    text t('partnership_deed.s6.c2_to_6')

    # Section 7: Sharing of Profits and Losses
    move_down 10
    text t('partnership_deed.s7.heading'), inline_format: true
    move_down 10
    text t('partnership_deed.s7.c1'), inline_format: true
    add_profit_sharing_table
    move_down 10
    text t('partnership_deed.s7.c2_to_3'), inline_format: true

    # Section 8: Financial year and accounts
    move_down 10
    text t('partnership_deed.s8'), inline_format: true

    # Section 9: Bank Account
    move_down 10
    text t('partnership_deed.s9'), inline_format: true

    # Section 10: Records and Books
    move_down 10
    text t('partnership_deed.s10'), inline_format: true

    # Section 11: Borrowing Powers
    move_down 10
    text t('partnership_deed.s11'), inline_format: true

    # Section 12: Covenants of the Partners
    move_down 10
    text t('partnership_deed.s12.heading'), inline_format: true
    text t('partnership_deed.s12.c1.heading')
    text t('partnership_deed.s12.c1.clauses'), indent_paragraphs: 30
    text t('partnership_deed.s12.c2.heading')
    text t('partnership_deed.s12.c2.clauses'), indent_paragraphs: 30

    # Section 13: Term
    move_down 10
    text t('partnership_deed.s13.part_1'), inline_format: true
    text t('partnership_deed.s13.part_2'), indent_paragraphs: 30

    # Section 14: Retirement or Death
    move_down 10
    text t('partnership_deed.s14.part_1'), inline_format: true
    text t('partnership_deed.s14.part_2'), indent_paragraphs: 30
    text t('partnership_deed.s14.part_3')
    text t('partnership_deed.s14.part_4'), indent_paragraphs: 30

    # Section 15: Miscellaneous
    move_down 10
    text t('partnership_deed.s15'), inline_format: true
  end
  # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

  def add_capital_contribution_table
    move_down 10
    table_rows = [['<b>Partner</b>', '<b>Amount</b>']]
    @batch_application.batch_applicants.each_with_index do |_batch_applicant, index|
      table_rows << ["#{(index + 1).ordinalize} Partner", '']
    end

    table table_rows, position: :center, width: 300, cell_style: { inline_format: true }
  end

  def add_profit_sharing_table
    move_down 10
    table_rows = [['<b>Partner</b>', '<b>Sharing Ratio (in percentage)</b>']]
    @batch_application.batch_applicants.each_with_index do |_batch_applicant, index|
      table_rows << ["#{(index + 1).ordinalize} Partner", '']
    end

    table table_rows, position: :center, width: 300, cell_style: { inline_format: true }
  end

  def add_signatures
    move_down 10
    text t('partnership_deed.signatures.header')
    @batch_application.batch_applicants.each_with_index { |_applicant, index| add_signature_section(index + 1) }
  end

  def add_signature_section(index)
    move_down 15
    text 'Signed and delivered by'
    move_down 10
    text '____________________________________'
    text "(the #{index.ordinalize} Partner)"
  end

  def t(*args)
    I18n.t(*args)
  end
end
