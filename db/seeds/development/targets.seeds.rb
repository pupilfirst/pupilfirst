require_relative 'helper'

after 'development:target_groups', 'development:faculty' do
  puts 'Seeding targets'

  startup_school = School.find_by(name: 'Startup')
  developer_school = School.find_by(name: 'Developer')
  vr_school = School.find_by(name: 'VR')
  ios_school = School.find_by(name: 'iOS')

  video_embed = '<iframe width="560" height="315" src="https://www.youtube.com/embed/58CPRi5kRe8" frameborder="0" allowfullscreen></iframe>'

  def paragraph
    Faker::Lorem.paragraphs.join("\n\n")
  end

  def session_taker_name
    Faker::Name.name
  end

  faculty = Faculty.first

  # Random targets and sessions for every level.
  Level.where.not(number: 0).each do |level|

    # Two vanilla targets and one session per target_group.
    level.target_groups.each do |target_group|
      # Targets.
      2.times do
        target_group.targets.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, target_group: target_group, description: paragraph, faculty: faculty, target_action_type: Target::TYPE_TODO, resubmittable: true)
      end

      # Session.
      target_group.targets.create!(title: Faker::Lorem.sentence, role: Target.valid_roles.sample, session_at: 1.month.ago, description: paragraph, session_by: session_taker_name, video_embed: video_embed, target_action_type: Target::TYPE_ATTEND, resubmittable: false)
    end
  end

  # Assign evaluation criteria for few targets in different schools

  Target.joins(:level).where(levels: { number: 1, school_id: startup_school.id }).each do |target|
    target.target_evaluation_criteria.create!(evaluation_criterion: startup_school.evaluation_criteria.first)
  end

  Target.joins(:level).where(levels: { number: 2, school_id: developer_school.id }).each do |target|
    target.target_evaluation_criteria.create!(evaluation_criterion: developer_school.evaluation_criteria.first)
  end

  Target.joins(:level).where(levels: { number: 3, school_id: vr_school.id }).each do |target|
    target.target_evaluation_criteria.create!(evaluation_criterion: vr_school.evaluation_criteria.first)
  end

  Target.joins(:level).where(levels: { number: 1, school_id: ios_school.id }).each do |target|
    target.target_evaluation_criteria.create!(evaluation_criterion: ios_school.evaluation_criteria.first)
  end
end
