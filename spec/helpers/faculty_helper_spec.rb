require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the FacultyHelper. For example:
#
# describe FacultyHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe FacultyHelper, type: :helper do
  describe '#faculty_image_path' do
    it 'returns image file path for faculty' do
      expect(helper.faculty_image_path(:visiting_faculty, 'Dr. Theodor S. Geisel')).to eq('faculty/visiting_faculty/theodor_s_geisel.png')
    end
  end
end
