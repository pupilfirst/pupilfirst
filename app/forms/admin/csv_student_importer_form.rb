# Accepts a CSV file and create teams
module Admin
  class CsvStudentImporterForm < Reform::Form
    property :file, validates: { presence: true }
    property :course_id, validates: { presence: true }

    validate :file_extension

    def file_extension
      return if file.blank?

      ext = File.extname(file.path)
      return if ext == '.csv'

      errors[:file] << 'invalid file format'
    end

    def save
      require 'csv'
      require 'open-uri'

      csv_data = File.open(file.path)
      student_data = CSV.parse(csv_data, headers: true)

      student_data.each do |row|
        founder_data = row.to_hash
        Founder.transaction do
          team = Startup.create!(name: founder_data['name'], level: level)
          user = user(founder_data['email'])
          user_profile = UserProfile.where(user: user, school: level.course.school).first_or_create!
          user_profile.update!(name: founder_data['name'])
          Founder.create!(user: user, startup: team)
        end
      end
    end

    private

    def level
      Course.find(course_id).levels.find_by(number: 1)
    end

    def user(email)
      u = User.where(email: email).first_or_create!
      u.regenerate_login_token if u.login_token.blank?
      u
    end
  end
end
