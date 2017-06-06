module MoocStudents
  class CompletionCertificate < Prawn::Document
    def initialize(mooc_student)
      @mooc_student = mooc_student
      super(margin: 0, page_size: 'A4', page_layout: :landscape)
      font 'Helvetica'
    end

    def build
      image Rails.root.join('app', 'assets', 'images', 'six_ways', 'completion-certificate.png'), width: bounds.width, at: bounds.top_left
      move_down 240
      text @mooc_student.name.upcase, align: :center, style: :bold, size: 20
      move_down 5
      text "of <i>'#{@mooc_student.college_name}'</i>", align: :center, inline_format: true
      move_down 67
      text_box "#{@mooc_student.score.round}%", at: [458, y], style: :bold, size: 16
      self
    end
  end
end
#
