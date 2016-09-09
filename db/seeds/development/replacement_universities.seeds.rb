after 'development:states' do
  gujarat = State.find_by(name: 'Gujarat')
  kerala = State.find_by(name: 'Kerala')

  [
    ['Gujarat Technological University, Ahmedabad', gujarat],
    ['University of Kerala, Thiruvananthapuram', kerala],
    ['Cochin University of Science and Technology, Kochi', kerala]
  ].each do |university_data|
    ReplacementUniversity.where(name: university_data[0], state: university_data[1]).first_or_create!
  end
end
