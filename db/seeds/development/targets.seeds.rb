require_relative 'helper'

after 'development:startups' do
  puts 'Seeding targets'

  avengers_startup = Startup.find_by(product_name: 'SuperHeroes')

  targets_list = [
    [avengers_startup, Faculty.first, 'founder', 'Upload Resume', 'Upload your latest resume!'],
    [avengers_startup, Faculty.second, 'engineering', 'Select Tech Stack', 'Decide on the tech stack that works for you'],
    [avengers_startup, Faculty.first, 'governance', 'Sign Agreements', 'Complete all your paperwork with SV.CO']
  ]

  targets_list.each do |startup, assigner, role, title, description|
    Target.create!(
      assignee: startup,
      assigner: assigner,
      role: role,
      title: title,
      description: description
    )
  end

  Target.last.update(due_date: 1.week.ago)
end
