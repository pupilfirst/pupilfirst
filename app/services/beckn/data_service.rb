module Beckn
  class DataService
    def initialize(payload)
      @payload = payload
    end

    def school_descriptor
      {
        name: @school.name,
        short_desc: SchoolString::Description.for(@school) || @school.name,
        long_desc: @school.about.presence || "",
        images: [
          image_data(@school.logo_on_light_bg, size: "lg"),
          image_data(@school.icon_on_light_bg, size: "sm"),
        ].compact,
      }
    end

    def school_categories
      @school.course_categories.map do |category|
        {
          id: category.id.to_s,
          descriptor: {
            code: category.id.to_s,
            name: category.name,
          },
        }
      end
    end

    def fullfillment_basics
      {
        agent: {
          person: {
            name: @school.name,
          },
          contact: {
            email: @school.email,
          },
        },
      }
    end

    def fullfillment_with_customer(customer)
      fullfillment_basics.merge(customer: customer)
    end

    def billing_details
      {
        name: @school.name,
        email: @school.email,
        address: SchoolString::Address.for(@school),
      }
    end

    def course_descriptor(course)
      {
        id: course.id.to_s,
        quantity: {
          maximum: {
            count: 1,
          },
        },
        descriptor: {
          name: course.name,
          short_desc: course.description.presence || "",
          long_desc: course.about.presence || "",
          additional_desc: {
            url: public_url("course_path", course.id),
            content_type: "text/html",
          },
          images: [
            image_data(course.thumbnail),
            image_data(course.cover),
          ].compact,
        },
        creator: {
          descriptor: school_descriptor,
        },
        price: {
          currency: "INR",
          value: "0",
        },
        category_ids: course.course_categories.pluck(:id).map(&:to_s),
        rating: course.rating.to_s,
        rateable: true,
        tags: [
          {
            descriptor: {
              code: "content-metadata",
              name: "Content metadata",
            },
            list:
              course.highlights.map do |tag|
                {
                  descriptor: {
                    code: tag["title"].downcase.tr(" ", "-"),
                    name: tag["title"],
                  },
                  value: tag["description"].to_s,
                }
              end,
            display: true,
          },
        ],
      }
    end

    def with_certificate(data)
      certificate =
        student
          .user
          .issued_certificates
          .joins(:certificate)
          .find_by(certificate: { course_id: student.course.id })

      if certificate.present?
        data[:tags] = [
          {
            descriptor: {
              code: "course-completion-details",
              name: "Content Completion Details",
            },
            list: [
              {
                descriptor: {
                  code: "course-certificate",
                  name: "Course certificate",
                },
                value:
                  public_url(
                    "issued_certificate_path",
                    certificate.serial_number,
                  ),
              },
            ],
            display: true,
          },
        ]
      end
      data
    end

    def find_student_in_bap(order_id)
      student = Student.find_by(id: order_id)

      if student&.metadata&.dig("beckn", "bap_id") !=
           @payload["context"]["bap_id"]
        return
      end

      student
    end

    def default_quote
      {
        price: {
          currency: Schools::Configuration.new(@school).default_currency,
          value: "0",
        },
      }
    end

    def error_response(code, message)
      Beckn::ErrorDataService.new.data(code, message)
    end

    def state_descriptor(code, name, updated_at)
      { descriptor: { code: code, name: name }, updated_at: updated_at }
    end

    def state_data
      if student.dropped_out_at?
        state_descriptor("CANCELLED", "Cancelled", student.dropped_out_at)
      elsif student.completed_at?
        state_descriptor("COMPLETED", "Completed", student.completed_at)
      elsif student.timeline_events.exists?
        state_descriptor(
          "IN_PROGRESS",
          "In Progress",
          student.user.last_sign_in_at,
        )
      else
        state_descriptor("NOT_STARTED", "Not Started", student.created_at)
      end
    end

    def with_milestone_data(course)
      course.targets.live.milestone.map do |target|
        target_status = Targets::StatusService.new(target, student).status
        {
          id: target.id.to_s,
          instructions: {
            name: target.title,
            media: [{ url: public_url("curriculum_course_path", course.id) }],
          },
          authorization: {
            status:
              (
                if target_status == Targets::StatusService::STATUS_PASSED
                  "COMPLETED"
                else
                  "NOT_STARTED"
                end
              ),
          },
        }
      end
    end

    def fullfillment_with_state
      student_data = {
        person: {
          name: student.user.name,
        },
        contact: {
          email: student.user.email,
        },
      }

      data = fullfillment_with_customer(student_data).merge(state: state_data)
      data = data.merge(stops: with_milestone_data(student.course))
      data = with_certificate(data) if student.completed_at?
      data
    end

    def image_data(image, size: nil)
      return unless image.attached?

      data = { url: image_url(image) }
      data[:size_type] = size if size
      data
    end

    def school_url
      "https://#{@school.domains.primary.fqdn}"
    end

    def image_url(image)
      path = Rails.application.routes.url_helpers.rails_public_blob_url(image)
      if ENV["CLOUDFRONT_HOST"].blank? || Rails.env.development?
        "#{school_url}#{path}"
      else
        path
      end
    end

    def public_url(*route)
      "#{school_url}#{Rails.application.routes.url_helpers.send(*route)}"
    end
  end
end
