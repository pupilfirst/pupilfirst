class MoocStudent
  # Imports student entries into mooc_students
  #
  # The CSV file is expected to contain a header with keys 'name', 'email', 'mobile', 'gender', college', and 'semester'.
  # The service also expects to be supplied with a University for which the import is to be performed.
  #
  # TODO: This script will fail once ReplacementUniversity replaces the University model for mooc_students. Update when applicable.
  class ImportService < BaseService
    attr_reader :source_csv_url, :university
    attr_accessor :invalid

    def initialize(source_csv_url, university, dry_run: true)
      @source_csv_url = source_csv_url
      @university = university
      @dry_run = dry_run
      @invalid = 0
    end

    def process
      load_data do |row|
        if invalid?(row)
          self.invalid += 1
          next
        end

        import_student(row)
      end

      log "Invalid entries skipped: #{invalid}"
    end

    private

    def dry_run?
      @dry_run
    end

    def load_data
      CSV.parse(open(source_csv_url).read, headers: true) do |row|
        yield row
      end
    end

    def import_student(row)
      data = clean_up(row)
      log "Importing #{data.inspect}"
      MoocStudent::RegistrationService.new(data).register unless dry_run?
    end

    def clean_up(data)
      {
        name: data['name'].titleize,
        email: data['email'].strip,
        phone: data['mobile'].strip[0..9],
        gender: gender_value(data['gender']),
        university_id: university.id,
        college: data['college'].titleize,
        semester: semester_value(data['semester'].strip),
        state: university.location
      }
    end

    def invalid?(data)
      !(data['name'].present? &&
        data['email'] =~ EmailValidator::REGULAR_EXPRESSION &&
        data['mobile'].present? &&
        data['mobile'].length >= 10 &&
        data['college'].present? &&
        data['semester'].present?)
    end

    def gender_value(gender)
      { 'M' => Founder::GENDER_MALE, 'F' => Founder::GENDER_FEMALE }[gender] || Founder::GENDER_MALE
    end

    def semester_value(number)
      { 1 => 'I', 2 => 'II', 3 => 'III', 4 => 'IV', 5 => 'V', 6 => 'VI', 7 => 'VII', 8 => 'VIII' }[number.to_i] || 'Other'
    end
  end
end
