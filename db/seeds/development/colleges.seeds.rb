after 'development:replacement_universities' do
  puts 'Seeding colleges'

  kerala = State.find_by name: 'Kerala'
  gujarat = State.find_by name: 'Gujarat'

  cusat = ReplacementUniversity.find_by name: 'Cochin University of Science and Technology, Kochi'
  ukt = ReplacementUniversity.find_by name: 'University of Kerala, Thiruvananthapuram'
  gtu = ReplacementUniversity.find_by name: 'Gujarat Technological University, Ahmedabad'

  [
    ['Cochin University of Science and Technology, Kochi', 'Ernakulam', kerala, cusat, nil],
    ['Government Model Engineering College, Thrikkakara', 'Ernakulam', kerala, cusat, 'MEC'],
    ['College of Engineering, Trivandrum', 'Thiruvananthapuram', kerala, ukt, 'CET'],
    ['Sree Chitra Thirunal College of Engineering', 'Thiruvananthapuram', kerala, ukt, 'SCT'],
    ['Birla Vishvakarma Mahavidyalaya, Anand', 'Anand', gujarat, gtu, 'BVM'],
    ['Vishwakarma Government Engineering College, Ahmedabad', 'Ahmedabad', gujarat, gtu, 'VGEC']
  ].each do |college_details|
    college = College.where(name: college_details[0]).first_or_initialize
    college.city = college_details[1]
    college.state = college_details[2]
    college.replacement_university = college_details[3]
    college.also_known_as = college_details[4]
    college.save!
  end
end
