names = ['Gujarat Technical University', 'Kerala University']

names.each do |name|
  University.create! name: name
end
