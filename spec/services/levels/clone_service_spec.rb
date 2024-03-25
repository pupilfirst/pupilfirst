require "rails_helper"

describe Levels::CloneService do
  include SubmissionsHelper

  subject { described_class.new }

  let(:school) { create :school }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:target_course) { create :course, school: school }
  let(:target_course_level_one) { create :level, :one, course: target_course }
  let(:level_zero) { create :level, :zero, course: course }
  let(:level_one) { create :level, :one, course: course }
  let(:level_two) { create :level, :two, course: course }

  let(:target_group_tc_l1) do
    create :target_group, level: target_course_level_one
  end

  let(:target_group_l0) { create :target_group, level: level_zero }

  let(:target_group_l1_1) { create :target_group, level: level_one }

  let(:target_group_l1_2) { create :target_group, level: level_one }

  let(:target_group_l2) { create :target_group, level: level_two }

  # prerequisite target
  let!(:prerequisite_target) do
    create :target,
           :with_shared_assignment,
           :with_content,
           target_group: target_group_l1_1,
           given_role: Assignment::ROLE_TEAM
  end

  let!(:target_tc_l1) do
    create :target,
           :with_content,
           :with_shared_assignment,
           given_role: Assignment::ROLE_TEAM,
           target_group: target_group_tc_l1
  end

  let!(:target_l0) do
    create :target,
           :with_content,
           :with_shared_assignment,
           given_role: Assignment::ROLE_TEAM,
           target_group: target_group_l0
  end

  let(:target_l1_1_1) do
    create :target,
           :with_content,
           :with_shared_assignment,
           given_role: Assignment::ROLE_TEAM,
           target_group: target_group_l1_1
  end

  let(:target_l1_1_2) do
    create :target,
           :with_content,
           :with_shared_assignment,
           given_role: Assignment::ROLE_TEAM,
           target_group: target_group_l1_1
  end

  let!(:target_l1_2) do
    create :target, :with_content, target_group: target_group_l1_2
  end

  let!(:assignment_target_l1_2) do
    create :assignment,
           prerequisite_assignments: [prerequisite_target.assignments.first],
           role: Assignment::ROLE_TEAM,
           target: target_l1_2,
           discussion: true,
           allow_anonymous: true
  end

  let(:target_l2_1) do
    create :target,
           :with_content,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l2
  end

  let!(:target_l2_2) do
    create :target,
           :with_content,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l2
  end

  let(:student_l1) { create :student, cohort: cohort }
  let(:student_l2) { create :student, cohort: cohort }
  let(:ec_1) { create :evaluation_criterion, course: course }
  let(:ec_2) { create :evaluation_criterion, course: course }

  let!(:quiz) { create :quiz }
  let!(:quiz_question_1) { create :quiz_question, quiz: quiz }
  let!(:q1_answer_1) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:q1_answer_2) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:quiz_question_2) { create :quiz_question, quiz: quiz }
  let!(:q2_answer_1) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_2) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_3) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_4) { create :answer_option, quiz_question: quiz_question_2 }

  # Quiz target
  let!(:quiz_target) do
    create :target,
           :with_content,
           target_group: target_group_l1_1,
           days_to_complete: 60
  end
  let!(:assignment_quiz_target) do
    create :assignment,
           :with_completion_instructions,
           quiz: quiz,
           target: quiz_target,
           role: Assignment::ROLE_TEAM
  end

  def file_path(filename)
    File.absolute_path(
      Rails.root.join("spec", "support", "uploads", "files", filename)
    )
  end

  before do
    complete_target(target_l1_1_1, student_l1)
    complete_target(target_l1_1_1, student_l2)
    complete_target(target_l1_1_2, student_l2)
    complete_target(target_l1_2, student_l2)
    complete_target(target_l2_1, student_l2)

    # Set correct answers for all quiz questions.
    quiz_question_1.update!(correct_answer: q1_answer_2)
    quiz_question_2.update!(correct_answer: q2_answer_4)

    # Set evaluation criteria for assignments
    target_l1_2.assignments.first.evaluation_criteria << ec_1

    # attach images
    course.cover.attach(
      io: File.open(file_path("logo_lipsum_on_light_bg.png")),
      filename: "logo_lipsum_on_light_bg.png"
    )

    course.thumbnail.attach(
      io: File.open(file_path("logo_lipsum_on_dark_bg.png")),
      filename: "logo_lipsum_on_dark_bg.png"
    )
  end

  describe "#clone" do
    it "creates a clone of the level into another course" do
      original_group_names = level_one.target_groups.pluck(:name)
      original_targets = level_one.targets.pluck(:title, :description)
      original_assignments =
        level_one
          .targets
          .joins(:assignments)
          .pluck(
            "assignments.role",
            "assignments.checklist",
            "assignments.milestone",
            "assignments.milestone_number",
            "assignments.archived",
            "assignments.completion_instructions",
            "assignments.discussion",
            "assignments.allow_anonymous"
          )
      original_student_count = Student.count
      original_submission_count = TimelineEvent.count

      original_quiz_questions =
        level_one
          .targets
          .flat_map { |t| t.assignments.first.quiz&.quiz_questions }
          .compact
          .pluck(:question, :description)

      original_answer_options =
        level_one
          .targets
          .flat_map { |t| t.assignments.first.quiz&.answer_options }
          .compact
          .pluck(:value, :hint)

      original_content_blocks =
        level_one.targets.map do |t|
          t
            .current_content_blocks
            .order(:sort_index)
            .map { |cb| cb.slice(:block_type, :content, :sort_index) }
        end

      original_content_blocks_count = original_content_blocks.sum(&:count)
      original_max_level = target_course.levels.maximum(:number)

      new_level = subject.clone(level_one, target_course)

      expect(new_level.course).to eq(target_course)

      # evaluation_criterion should have been cloned
      expect(course.evaluation_criteria.pluck(:name)).to include(
        *target_course.evaluation_criteria.pluck(:name)
      )

      # Levels, target groups, and targets should have been cloned.
      expect(new_level.name).to eq(level_one.name)
      expect(new_level.number).to eq(original_max_level + 1)

      expect(new_level.target_groups.pluck(:name)).to match_array(
        original_group_names
      )

      expect(new_level.targets.pluck(:title, :description)).to match_array(
        original_targets
      )

      expect(
        new_level
          .targets
          .joins(:assignments)
          .pluck(
            "assignments.role",
            "assignments.checklist",
            "assignments.milestone",
            "assignments.milestone_number",
            "assignments.archived",
            "assignments.completion_instructions",
            "assignments.discussion",
            "assignments.allow_anonymous"
          )
      ).to match_array(original_assignments)

      # Quiz, quiz questions and answer options should have been cloned
      new_quiz =
        new_level.targets.joins(assignments: :quiz).first.assignments.first.quiz

      expect(
        new_quiz.quiz_questions.pluck(:question, :description)
      ).to match_array(original_quiz_questions)

      expect(new_quiz.answer_options.pluck(:value, :hint)).to match_array(
        original_answer_options
      )

      # prerequisite target should been linked
      expect(
        new_level
          .targets
          .joins(assignments: :prerequisite_assignments)
          .first
          .assignments
          .first
          .prerequisite_assignments
          .first
          .target
          .title
      ).to eq(prerequisite_target.title)

      evaluated_targets =
        new_level.targets.joins(assignments: :assignments_evaluation_criteria)
      expect(evaluated_targets.count).to eq(1)

      expect(
        evaluated_targets.first.evaluation_criteria.pluck(
          :name,
          :max_grade,
          :grade_labels
        )
      ).to eq([[ec_1.name, ec_1.max_grade, ec_1.grade_labels]])

      # content block should have been cloned
      expect(
        new_level.targets.flat_map { |t| t.current_content_blocks }.count
      ).to eq(original_content_blocks_count)

      expect(
        new_level.targets.map do |t|
          t
            .current_content_blocks
            .order(:sort_index)
            .map { |cb| cb.slice(:block_type, :content, :sort_index) }
        end
      ).to match_array(original_content_blocks)

      # There should be no cloning of students, or timeline events.
      expect(Student.count).to eq(original_student_count)
      expect(TimelineEvent.count).to eq(original_submission_count)
    end

    it "does not renumber level 0 if it doesn't exist in the target course" do
      original_level_count = target_course.levels.count

      new_level = subject.clone(level_zero, target_course)

      expect(target_course.levels.count).to eq(original_level_count + 1)
      expect(new_level.number).to eq(0)
    end

    it "create a clone of the level into the same course" do
      original_level_names = course.levels.pluck(:name)
      original_group_names = level_one.target_groups.pluck(:name)
      original_targets = level_one.targets.pluck(:title, :description)
      original_assignments =
        level_one
          .targets
          .joins(:assignments)
          .pluck(
            "assignments.role",
            "assignments.checklist",
            "assignments.milestone",
            "assignments.milestone_number",
            "assignments.archived",
            "assignments.completion_instructions",
            "assignments.discussion",
            "assignments.allow_anonymous"
          )
      original_student_count = Student.count
      original_submission_count = TimelineEvent.count

      original_quiz_questions =
        level_one
          .targets
          .flat_map { |t| t.assignments.first.quiz&.quiz_questions }
          .compact
          .pluck(:question, :description)

      original_answer_options =
        level_one
          .targets
          .flat_map { |t| t.assignments.first.quiz&.answer_options }
          .compact
          .pluck(:value, :hint)

      original_content_blocks =
        level_one.targets.map do |t|
          t
            .current_content_blocks
            .order(:sort_index)
            .map { |cb| cb.slice(:block_type, :content, :sort_index) }
        end

      original_content_blocks_count = original_content_blocks.sum(&:count)

      new_level = subject.clone(level_one, course)

      expect(new_level.course).to eq(course)

      # evaluation_criterion should have been cloned
      expect(course.evaluation_criteria.pluck(:name)).to include(
        *target_course.evaluation_criteria.pluck(:name)
      )

      # Levels, target groups, and targets should have been cloned.
      expect(new_level.name).to eq(level_one.name)

      expect(new_level.target_groups.pluck(:name)).to match_array(
        original_group_names
      )

      expect(new_level.targets.pluck(:title, :description)).to match_array(
        original_targets
      )

      expect(
        new_level
          .targets
          .joins(:assignments)
          .pluck(
            "assignments.role",
            "assignments.checklist",
            "assignments.milestone",
            "assignments.milestone_number",
            "assignments.archived",
            "assignments.completion_instructions",
            "assignments.discussion",
            "assignments.allow_anonymous"
          )
      ).to match_array(original_assignments)

      # Quiz, quiz questions and answer options should have been cloned
      new_quiz =
        new_level.targets.joins(assignments: :quiz).first.assignments.first.quiz

      expect(
        new_quiz.quiz_questions.pluck(:question, :description)
      ).to match_array(original_quiz_questions)

      expect(new_quiz.answer_options.pluck(:value, :hint)).to match_array(
        original_answer_options
      )

      # prerequisite target should been linked
      expect(
        new_level
          .targets
          .joins(assignments: :prerequisite_assignments)
          .first
          .assignments
          .first
          .prerequisite_assignments
          .first
          .target
          .title
      ).to eq(prerequisite_target.title)

      evaluated_targets =
        new_level.targets.joins(assignments: :assignments_evaluation_criteria)
      expect(evaluated_targets.count).to eq(1)

      expect(
        evaluated_targets.first.evaluation_criteria.pluck(
          :name,
          :max_grade,
          :grade_labels
        )
      ).to eq([[ec_1.name, ec_1.max_grade, ec_1.grade_labels]])

      # content block should have been cloned
      expect(
        new_level.targets.flat_map { |t| t.current_content_blocks }.count
      ).to eq(original_content_blocks_count)

      expect(
        new_level.targets.map do |t|
          t
            .current_content_blocks
            .order(:sort_index)
            .map { |cb| cb.slice(:block_type, :content, :sort_index) }
        end
      ).to match_array(original_content_blocks)

      # There should be no cloning of students, or timeline events.
      expect(Student.count).to eq(original_student_count)
      expect(TimelineEvent.count).to eq(original_submission_count)

      # level should be added to the course
      expect(course.levels.pluck(:name)).to match_array(
        original_level_names + [new_level.name]
      )
    end
  end
end
