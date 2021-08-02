require 'rails_helper'

describe Levels::CloneService do
  include SubmissionsHelper

  subject { described_class.new }

  let(:school) { create :school }
  let(:course) { create :course, school: school }
  let(:target_course) { create :course, school: school }
  let(:level_one) { create :level, :one, course: course }
  let(:level_two) { create :level, :two, course: course }
  let(:target_group_l1_1) { create :target_group, level: level_one, milestone: true }
  let(:target_group_l1_2) { create :target_group, level: level_one }
  let(:target_group_l2) { create :target_group, level: level_two, milestone: true }
  let(:target_l1_1_1) { create :target, :with_content, :for_team, target_group: target_group_l1_1 }
  let(:target_l1_1_2) { create :target, :with_content, :for_team, target_group: target_group_l1_1 }
  let(:target_l1_2) { create :target, :with_content, :for_team, target_group: target_group_l1_2 }
  let(:target_l2_1) { create :target, :with_content, :for_founders, target_group: target_group_l2 }
  let!(:target_l2_2) { create :target, :with_content, :for_founders, target_group: target_group_l2 }
  let(:startup_l1) { create :startup, level: level_one }
  let(:startup_l2) { create :startup, level: level_two }
  let(:ec_1) { create :evaluation_criterion, course: course }
  let(:ec_2) { create :evaluation_criterion, course: course }

  # Quiz target
  let!(:quiz_target) { create :target, :with_content, target_group: target_group_l1_1, days_to_complete: 60, role: Target::ROLE_TEAM, resubmittable: false, completion_instructions: Faker::Lorem.sentence }
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
  let!(:prerequisite_target) { create :target, :with_content, target_group: target_group_l1_1, role: Target::ROLE_TEAM }

  def file_path(filename)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'files', filename))
  end

  before do
    complete_target(target_l1_1_1, startup_l1.founders.first)
    complete_target(target_l1_1_1, startup_l2.founders.first)
    complete_target(target_l1_1_2, startup_l2.founders.first)
    complete_target(target_l1_2, startup_l2.founders.first)
    complete_target(target_l2_1, startup_l2.founders.first)

    # Set correct answers for all quiz questions.
    quiz_question_1.update!(correct_answer: q1_answer_2)
    quiz_question_2.update!(correct_answer: q2_answer_4)

    # set prerequisite target
    target_l1_2.prerequisite_targets << prerequisite_target
    target_l1_2.evaluation_criteria << ec_1
    # attach images
    course.cover.attach(io: File.open(file_path('logo_lipsum_on_light_bg.png')), filename: 'logo_lipsum_on_light_bg.png')
    course.thumbnail.attach(io: File.open(file_path('logo_lipsum_on_dark_bg.png')), filename: 'logo_lipsum_on_dark_bg.png')
  end

  describe '#clone' do
    it 'create a clone of the  level into another course' do
      original_group_names = level_one.target_groups.pluck(:name)
      original_targets = level_one.targets.pluck(:title, :description)
      original_startup_count = Startup.count
      original_founder_count = Founder.count
      original_submission_count = TimelineEvent.count
      original_quiz_questions = level_one.targets.flat_map{|t| t.quiz&.quiz_questions}.compact.pluck(:question, :description)
      original_answer_options = level_one.targets.flat_map{|t| t.quiz&.answer_options}.compact.pluck(:value, :hint)
      original_content_blocks = level_one.targets.map { |t| t.current_content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) } }
      original_content_blocks_count = original_content_blocks.sum(&:count)

      new_level = subject.clone(level_one, target_course)

      expect(new_level.course).to eq(target_course)

      # evaluation_criterion should have been cloned
      expect(course.evaluation_criteria.pluck(:name)).to include(*target_course.evaluation_criteria.pluck(:name))

      # Levels, target groups, and targets should have been cloned.
      expect(new_level.name).to eq(level_one.name)
      expect(new_level.target_groups.pluck(:name)).to match_array(original_group_names)
      expect(new_level.targets.pluck(:title, :description)).to match_array(original_targets)

      # Quiz, quiz questions and answer options should have been cloned
      new_quiz = new_level.targets.joins(:quiz).first.quiz
      expect(new_quiz.quiz_questions.pluck(:question, :description)).to match_array(original_quiz_questions)
      expect(new_quiz.answer_options.pluck(:value, :hint)).to match_array(original_answer_options)

      # prerequisite target should been linked
      expect(new_level.targets.joins(:prerequisite_targets).first.prerequisite_targets.first.title).to eq(prerequisite_target.title)

      evaluated_targets = new_level.targets.joins(:target_evaluation_criteria)
      expect(evaluated_targets.count).to eq(1)
      expect(evaluated_targets.first.evaluation_criteria.pluck(:name, :max_grade, :pass_grade, :grade_labels)).to eq([[ec_1.name, ec_1.max_grade, ec_1.pass_grade, ec_1.grade_labels]])

      # content block should have been cloned
      expect(new_level.targets.flat_map{|t| t.current_content_blocks}.count).to eq(original_content_blocks_count)
      expect(new_level.targets.map { |t| t.current_content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) } }).to match_array(original_content_blocks)
      # There should be no cloning of startups, founders, or timeline events.
      expect(Startup.count).to eq(original_startup_count)
      expect(Founder.count).to eq(original_founder_count)
      expect(TimelineEvent.count).to eq(original_submission_count)
    end

    it 'create a clone of the level into the same course' do
      original_level_names = course.levels.pluck(:name)
      original_group_names = level_one.target_groups.pluck(:name)
      original_targets = level_one.targets.pluck(:title, :description)
      original_startup_count = Startup.count
      original_founder_count = Founder.count
      original_submission_count = TimelineEvent.count
      original_quiz_questions = level_one.targets.flat_map{|t| t.quiz&.quiz_questions}.compact.pluck(:question, :description)
      original_answer_options = level_one.targets.flat_map{|t| t.quiz&.answer_options}.compact.pluck(:value, :hint)
      original_content_blocks = level_one.targets.map { |t| t.current_content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) } }
      original_content_blocks_count = original_content_blocks.sum(&:count)

      new_level = subject.clone(level_one, course)

      expect(new_level.course).to eq(course)

      # evaluation_criterion should have been cloned
      expect(course.evaluation_criteria.pluck(:name)).to include(*target_course.evaluation_criteria.pluck(:name))

      # Levels, target groups, and targets should have been cloned.
      expect(new_level.name).to eq(level_one.name)
      expect(new_level.target_groups.pluck(:name)).to match_array(original_group_names)
      expect(new_level.targets.pluck(:title, :description)).to match_array(original_targets)

      # Quiz, quiz questions and answer options should have been cloned
      new_quiz = new_level.targets.joins(:quiz).first.quiz
      expect(new_quiz.quiz_questions.pluck(:question, :description)).to match_array(original_quiz_questions)
      expect(new_quiz.answer_options.pluck(:value, :hint)).to match_array(original_answer_options)

      # prerequisite target should been linked
      expect(new_level.targets.joins(:prerequisite_targets).first.prerequisite_targets.first.title).to eq(prerequisite_target.title)

      evaluated_targets = new_level.targets.joins(:target_evaluation_criteria)
      expect(evaluated_targets.count).to eq(1)
      expect(evaluated_targets.first.evaluation_criteria.pluck(:name, :max_grade, :pass_grade, :grade_labels)).to eq([[ec_1.name, ec_1.max_grade, ec_1.pass_grade, ec_1.grade_labels]])

      # content block should have been cloned
      expect(new_level.targets.flat_map{|t| t.current_content_blocks}.count).to eq(original_content_blocks_count)
      expect(new_level.targets.map { |t| t.current_content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) } }).to match_array(original_content_blocks)
      # There should be no cloning of startups, founders, or timeline events.
      expect(Startup.count).to eq(original_startup_count)
      expect(Founder.count).to eq(original_founder_count)
      expect(TimelineEvent.count).to eq(original_submission_count)

      # level should be added to the course
      expect(course.levels.pluck(:name)).to match_array(original_level_names + [new_level.name])
    end
  end
end
