colleges = [
  ['International School of Photonics, Cochin', 'CUSAT'],
  ['Indian Institute of Space Science and Technology Thiruvananthapuram', 'IIST'],
  ['Co-Operative Arts and Science College, Pazhayangadi', 'Kannur University']
]

colleges.each do |college|
  College.create! name: college[0], university: college[1]
end
