universities = [
  ['Gujarat Technical University', 'Gujarat'],
  ['Kerala University', 'Kerala'],
  ['Cochin University of Science and Technology', 'Kerala'],
  ['-- Other University not in this List --', 'Other']
]

universities.each do |university|
  University.create! name: university[0], location: university[1]
end
