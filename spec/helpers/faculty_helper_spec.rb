require 'rails_helper'

RSpec.describe FacultyHelper, type: :helper do
  describe '#faculty_image_path' do
    it 'returns image file path for faculty' do
      expect(helper.faculty_image_path(:visiting_faculty, 'Dr. Theodor S. Geisel')).to eq('faculty/visiting_faculty/theodor_s_geisel.png')
    end
  end
end
