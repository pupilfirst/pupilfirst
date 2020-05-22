module Schools
  module Coaches
    class CreateForm < Reform::Form
      property :email, validates: { email: true }, virtual: true
      property :name, validates: { presence: true, length: { maximum: 250 } }, virtual: true
      property :title, validates: { presence: true, length: { maximum: 250 } }, virtual: true
      property :connect_link
      property :public
      property :image, virtual: true, validates: { image: true, file_size: { less_than: 5.megabytes }, allow_blank: true }
      property :school_id, virtual: true, validates: { presence: true }
      property :affiliation, virtual: true

      def save
        Faculty.transaction do
          ::FacultyModule::CreateService.new(faculty_params).create
        end
      end

      private

      def school
        School.find_by(id: school_id)
      end

      def faculty_params
        {
          name: name,
          email: email,
          title: title,
          school: school,
          connect_link: connect_link,
          public: public,
          image: image,
          affiliation: affiliation
        }
      end
    end
  end
end
