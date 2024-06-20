module Beckn::Api
  class OnConfirmDataService < Beckn::DataService
    def execute
      # |30001|Provider not found|When BPP is unable to find the provider id sent by the BAP|
      return error_response("30001", "School not found") if school.blank?
      # |30004|Item not found|When BPP is unable to find the item id sent by the BAP|
      return error_response("30004", "Course not found") if course.blank?
      # |30008|Fulfillment unavailable|When BPP is unable to find the fulfillment id sent by the BAP|
      return error_response("30008", "Customer not found") if customer.blank?
      # |30008|Fulfillment unavailable|When a user is not just a student|
      if not_just_a_student?
        return(
          error_response(
            "30008",
            "Beckn is enabled only for students, please contact the school admin",
          )
        )
      end
      # |30008|Fulfillment unavailable|When the student is already present in the course and the BAP id doesn't match|
      student = find_student

      if bap_mismatch?(student)
        return error_response("30008", "BAP id doesn't match")
      end

      student = create_student if student.blank?

      {
        message: {
          order: {
            id: student.id.to_s,
            provider: {
              id: school.id.to_s,
              descriptor: school_descriptor,
              categories: [],
            },
            items: [course_descriptor(course)],
            fulfillments: [
              with_stops_for_confirm(
                fullfillment_with_customer(customer),
                student,
              ),
            ],
            quote: default_quote,
            billing: {
            },
            payments: [],
          },
        },
      }
    end

    def find_student
      course.students.joins(:user).find_by(user: user)
    end

    def bap_mismatch?(student)
      # If a student is already present in the course, then the BAP id should match
      return false if student.blank?

      student.metadata.dig("beckn", "bap_id") != @payload["context"]["bap_id"]
    end

    def user
      @user ||= school.users.find_by(email: customer["contact"]["email"])
    end

    def not_just_a_student?
      return false if user.blank?

      return true if user.school_admin.present?

      return true if user.faculty.present?

      user.course_authors.exists?
    end

    def with_stops_for_confirm(data, student)
      user = student.user
      user.regenerate_login_token
      data[:stops] = [
        {
          id: @school.id.to_s,
          instructions: {
            name: "View Course",
            long_desc: "View course details",
            media: [
              {
                url:
                  public_url(
                    "user_token_path",
                    {
                      token: user.original_login_token,
                      referrer:
                        Rails
                          .application
                          .routes
                          .url_helpers
                          .curriculum_course_path(course),
                      shared_device: false,
                    },
                  ),
              },
            ],
          },
        },
      ]
      data
    end

    def create_student
      return unless customer_present?

      students = [
        OpenStruct.new(
          name: customer["person"]["name"],
          email: customer["contact"]["email"],
        ),
      ]

      # Add student to default cohort
      Cohorts::AddStudentsService.new(course.default_cohort, notify: false).add(
        students,
      )

      student = find_student

      student.update!(
        metadata: {
          beckn: {
            bap_id: @payload["context"]["bap_id"],
            bap_uri: @payload["context"]["bap_uri"],
            transaction_id: @payload["context"]["transaction_id"],
          },
        },
      )
      student
    end

    def customer_present?
      customer.present? && customer["person"]["name"].present? &&
        customer["contact"]["email"].present?
    end

    def customer
      @customer = order["fulfillments"].first["customer"]
    end

    def course
      @course ||=
        school.courses.beckn_enabled.find_by(id: order["items"].first["id"])
    end

    def school
      @school ||= School.beckn_enabled.find_by(id: order["provider"]["id"])
    end

    def order
      @order = @payload["message"]["order"]
    end
  end
end
