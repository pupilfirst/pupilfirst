module Beckn
  class DataService
    # This is a base class for all Beckn data services
    # It provides common methods and attributes that are shared across all services

    def school_descriptor
      {
        name: @school.name,
        short_desc: SchoolString::Description.for(@school) || @school.name,
        long_desc: @school.about.presence || "",
        images: [
          image_data(@school.logo_on_light_bg, size: "lg"),
          image_data(@school.icon_on_light_bg, size: "sm")
        ].compact
      }
    end

    def fullfillment_basics
      {
        agent: {
          person: {
            name: @school.name
          },
          contact: {
            email: @school.email
          }
        }
      }
    end

    def fullfillment_with_customer(customer)
      fullfillment_basics.merge(customer: customer)
    end

    def billing_details
      {
        name: @school.name,
        email: @school.email,
        address: SchoolString::Address.for(@school)
      }
    end

    def course_descriptor(course)
      {
        id: course.id.to_s,
        quantity: {
          maximum: {
            count: 1
          }
        },
        descriptor: {
          name: course.name,
          short_desc: course.description.presence || "",
          long_desc: course.about.presence || "",
          additional_desc: {
            url: public_url("course_path", course.id),
            content_type: "text/html"
          },
          images: [
            image_data(course.thumbnail),
            image_data(course.cover)
          ].compact
        },
        creator: {
          descriptor: school_descriptor
        },
        price: {
          currency: "INR",
          value: "0"
        },
        category_ids: [],
        rating: "5",
        rateable: true,
        tags: [
          {
            descriptor: {
              code: "content-metadata",
              name: "Content metadata"
            },
            list:
              course.highlights.map do |tag|
                {
                  descriptor: {
                    code: tag["title"].downcase.gsub(" ", "-"),
                    name: tag["title"]
                  },
                  value: tag["description"].to_s
                }
              end,
            display: true
          }
        ]
      }
    end

    def course_descriptor_with_stops(student)
      data = course_descriptor(student.course)
      user = student.user
      user.regenerate_login_token
      data[:stops] = [
        {
          id: id.to_s,
          instructions: {
            name: "View Course",
            long_desc: "View course details",
            media: [{ url: course_url(user.original_login_token) }]
          }
        }
      ]
      data
    end

    def default_quote
      { price: { currency: "INR", value: "0" } }
    end

    def error_response(code, message)
      Api::ErrorDataService.new.data(code, message)
    end

    private

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
      "#{school_url}#{Rails.application.routes.url_helpers.rails_public_blob_url(image)}"
    end

    def public_url(*route)
      "#{school_url}#{Rails.application.routes.url_helpers.send(*route)}"
    end
  end
end
