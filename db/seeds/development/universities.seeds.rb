universities = [
  ['Gujarat Technical University', 'Gujarat'],
  ['Kerala University', 'Kerala']
]

universities.each do |university|
  University.create! name: university[0], location: university[1]
end
