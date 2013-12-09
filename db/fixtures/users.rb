User.seed(:id) do |s|
	s.id = 1
  s.username = "jon"
  s.email = "jon@example.com"
  s.fullname = "Jon Max"
  s.remote_avatar_url = 'http://lh3.googleusercontent.com/-DDgV8Xyk9wI/AAAAAAAAAAI/AAAAAAAAAB4/Br4Lhao1m7U/photo.jpg'
end

User.seed(:id) do |s|
	s.id = 2
  s.username = "nakul"
  s.email = "jon@example.com"
  s.fullname = "Kakul Nabra"
  s.remote_avatar_url = 'http://nwassets.s3.amazonaws.com/assets/home/nakul-d305c6e1b382638568163bbdc48677e2.jpg'
end
