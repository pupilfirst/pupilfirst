module Targets
  class RubricPdf < Prawn::Document
    def initialize(target)
      @target = target
      super(margin: 20, page_size: 'A4', page_layout: :landscape)
    end

    def build
      image Rails.root.join('app', 'assets', 'images', 'shared', 'logo-png.png'), width: 100, at: bounds.top_left

      move_down 55

      text "RUBRIC FOR TARGET: #{@target.title}", align: :left, style: :bold, size: 10

      move_down 10
      table(data_header, column_widths: [35, 190, 190, 190, 190], cell_style: { size: 9, font_style: :bold, align: :center, border_width: 1.5 })
      move_down 1
      table(data_rubric, column_widths: [35, 190, 190, 190, 190], row_colors: %w[FFFFFF E0F2F1], cell_style: { size: 9, borders: %i[right bottom left], border_lines: %i[dotted dotted dotted dotted], padding: [10, 10, 10, 10] })
      self
    end

    private

    def data_header
      [%w[Sl.No Description Good Great Wow]]
    end

    def data_rubric
      @target.target_skills.each_with_object([]).with_index do |(target_skill, data), index|
        data << [index + 1, target_skill.skill.description, target_skill.rubric_good, target_skill.rubric_great, target_skill.rubric_wow]
      end
    end
  end
end
