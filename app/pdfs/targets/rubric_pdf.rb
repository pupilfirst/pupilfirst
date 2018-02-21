module Targets
  class RubricPdf < Prawn::Document
    def initialize(target, founder)
      @target = target
      @founder = founder
      @grades = grades_for_skills(founder)
      super(margin: 20, page_size: 'A4', page_layout: :landscape)
    end

    # rubocop:disable Metrics/AbcSize
    def build
      image Rails.root.join('app', 'assets', 'images', 'shared', 'logo-color.png'), width: 100, at: bounds.top_left
      move_down 55

      text document_title, align: :left, style: :bold, size: 10
      move_down 10

      table(data_header, column_widths: column_widths, cell_style: cell_style_for_header)
      move_down 1

      table(table_data, column_widths: column_widths, row_colors: row_colors, cell_style: cell_style_for_rubric_data) do
        # The block passed to table method cannot use methods or instance variables from class RubricPdf. These are outside
        # its scope and lead to a memory leak.
        (0..row_length - 1).each do |row_index|
          grade = cells[row_index, column_length - 1].content
          graded_column = { 'Good' => 1, 'Great' => 2, 'Wow' => 3 }[grade]
          cells[row_index, graded_column].background_color = 'FFDDA2' if graded_column.present?
        end
      end

      legend_box if @grades.present?

      self
    end

    # rubocop:enable Metrics/AbcSize

    private

    def data_header
      if @grades.present?
        [%w[Skill Good Great Wow Grade]]
      else
        [%w[Skill Good Great Wow]]
      end
    end

    def table_data
      @grades.present? ? data_grading : data_rubric
    end

    def data_rubric
      @target.target_skills.includes(:skill).map do |target_skill|
        ["<b>#{target_skill.skill.name}<br/><br/></b>" + target_skill.skill.description, target_skill.rubric_good, target_skill.rubric_great, target_skill.rubric_wow]
      end
    end

    def data_grading
      @target.target_skills.includes(:skill).map do |target_skill|
        ["<b>#{target_skill.skill.name}<br/><br/></b>" + target_skill.skill.description, target_skill.rubric_good, target_skill.rubric_great, target_skill.rubric_wow, @grades[target_skill.skill_id].titleize]
      end
    end

    def cell_style_for_header
      { size: 9, font_style: :bold, align: :center, border_width: 1.5 }
    end

    def cell_style_for_rubric_data
      { inline_format: true, size: 9, borders: %i[right bottom left], border_lines: %i[dotted dotted dotted dotted], padding: [10, 10, 10, 10] }
    end

    def column_widths
      @grades.present? ? [130, 205, 205, 205, 50] : [150, 215, 215, 215]
    end

    def legend_box
      bounding_box([625, 510], width: 170, height: 20) do
        colour_cell = make_cell(content: '', background_color: 'FFDDA2')
        table([[colour_cell, 'Awarded grade for a skill']], column_widths: [30, 140], cell_style: { size: 10, height: 19, align: :left, border_width: 0 })
      end
    end

    def grades_for_skills(founder)
      return unless @target.verified?(founder)
      return if @target.latest_linked_event(founder).timeline_event_grades.blank?
      @grades = @target.latest_linked_event(founder).timeline_event_grades.each_with_object({}) do |te_grade, grades|
        grades[te_grade.skill_id] = te_grade.grade
      end
    end

    def row_colors
      @grades.present? ? %w[FFFFFF FFFFFF] : %w[FFFFFF E0F2F1]
    end

    def document_title
      title_start = @grades.present? ? 'SCORESHEET' : 'RUBRIC'
      "#{title_start} FOR TARGET: #{@target.title}"
    end
  end
end
