require "rails_helper"

describe Courses::CloneService do
  include SubmissionsHelper

  subject { described_class.new(course) }

  let(:school) { create :school }
  let(:new_school) { create :school }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:level_zero) { create :level, :zero, course: course }
  let(:level_one) { create :level, :one, course: course }
  let(:level_two) { create :level, :two, course: course }
  let(:target_group_l0) { create :target_group, level: level_zero }

  let(:target_group_l1_1) { create :target_group, level: level_one }

  let(:target_group_l1_2) { create :target_group, level: level_one }

  let(:target_group_l2) { create :target_group, level: level_two }

  let!(:target_l0) do
    create :target, :with_content, :for_team, target_group: target_group_l0
  end

  let(:target_l1_1_1) do
    create :target, :with_content, :for_team, target_group: target_group_l1_1
  end

  let(:target_l1_1_2) do
    create :target, :with_content, :for_team, target_group: target_group_l1_1
  end

  let(:target_l1_2) do
    create :target, :with_content, :for_team, target_group: target_group_l1_2
  end

  let(:target_l2_1) do
    create :target, :with_content, :for_students, target_group: target_group_l2
  end

  let!(:target_l2_2) do
    create :target, :with_content, :for_students, target_group: target_group_l2
  end

  let!(:team) { create :team_with_students, cohort: cohort }
  let(:student_l1) { create :student, cohort: cohort }
  let(:student_l2) { create :student, cohort: cohort }

  let(:ec_1) { create :evaluation_criterion, course: course }
  let(:ec_2) { create :evaluation_criterion, course: course }
  let(:new_name) { Faker::Lorem.words(number: 2).join(" ") }

  # Quiz target
  let!(:quiz_target) do
    create :target,
           :with_content,
           target_group: target_group_l1_1,
           days_to_complete: 60,
           role: Target::ROLE_TEAM,
           resubmittable: false,
           completion_instructions: Faker::Lorem.sentence
  end

  let!(:quiz) { create :quiz, target: quiz_target }
  let!(:quiz_question_1) { create :quiz_question, quiz: quiz }
  let!(:q1_answer_1) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:q1_answer_2) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:quiz_question_2) { create :quiz_question, quiz: quiz }
  let!(:q2_answer_1) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_2) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_3) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_4) { create :answer_option, quiz_question: quiz_question_2 }

  # prerequisite target
  let!(:prerequisite_target) do
    create :target,
           :with_content,
           target_group: target_group_l1_1,
           role: Target::ROLE_TEAM
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

    # set prerequisite target
    target_l1_2.prerequisite_targets << prerequisite_target
    target_l1_2.evaluation_criteria << ec_1

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
    it "create a clone of the course with the supplied name" do
      original_levels = Level.all.order(:number).pluck(:number, :name)
      original_group_names = TargetGroup.all.pluck(:name)
      original_targets = Target.all.pluck(:title, :description)
      original_team_count = Team.count
      original_student_count = Student.count
      original_submission_count = TimelineEvent.count
      original_quiz_questions = QuizQuestion.all.pluck(:question, :description)
      original_answer_options = AnswerOption.all.pluck(:value, :hint)
      original_content_blocks_count = ContentBlock.count

      original_content_blocks =
        Target.all.map do |t|
          t
            .current_content_blocks
            .order(:sort_index)
            .map { |cb| cb.slice(:block_type, :content, :sort_index) }
        end

      new_course = subject.clone(new_name, new_school)

      expect(new_course.name).to eq(new_name)
      expect(new_course.school).to eq(new_school)

      # evaluation_criterion should have been cloned
      expect(new_course.evaluation_criteria.pluck(:name)).to match_array(
        course.evaluation_criteria.pluck(:name)
      )

      # Levels, target groups, and targets should have been cloned.
      expect(new_course.levels.order(:number).pluck(:number, :name)).to eq(
        original_levels
      )

      expect(new_course.target_groups.pluck(:name)).to match_array(
        original_group_names
      )

      expect(new_course.targets.pluck(:title, :description)).to match_array(
        original_targets
      )

      # Quiz, quiz questions and answer options should have been cloned
      new_quiz = new_course.targets.joins(:quiz).first.quiz

      expect(
        new_quiz.quiz_questions.pluck(:question, :description)
      ).to match_array(original_quiz_questions)

      expect(new_quiz.answer_options.pluck(:value, :hint)).to match_array(
        original_answer_options
      )

      # prerequisite target should been linked
      expect(
        new_course
          .targets
          .joins(:prerequisite_targets)
          .first
          .prerequisite_targets
          .first
          .title
      ).to eq(prerequisite_target.title)

      evaluated_targets = new_course.targets.joins(:target_evaluation_criteria)
      expect(evaluated_targets.count).to eq(1)

      expect(
        evaluated_targets.first.evaluation_criteria.pluck(
          :name,
          :max_grade,
          :pass_grade,
          :grade_labels
        )
      ).to eq([[ec_1.name, ec_1.max_grade, ec_1.pass_grade, ec_1.grade_labels]])

      # content block should have been cloned
      expect(new_course.content_blocks.count).to eq(
        original_content_blocks_count
      )

      expect(
        new_course.targets.map do |t|
          t
            .current_content_blocks
            .order(:sort_index)
            .map { |cb| cb.slice(:block_type, :content, :sort_index) }
        end
      ).to match_array(original_content_blocks)

      # There should be no cloning of team, students, or timeline events.
      expect(Team.count).to eq(original_team_count)
      expect(Student.count).to eq(original_student_count)
      expect(TimelineEvent.count).to eq(original_submission_count)

      expect(new_course.cover).to be_attached
      expect(new_course.thumbnail).to be_attached
    end
  end
end
