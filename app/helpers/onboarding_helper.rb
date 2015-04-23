module OnboardingHelper
    def valid_gender_values
    {
      'Male' => User::GENDER_MALE,
      'Female' => User::GENDER_FEMALE,
      'Other' => User::GENDER_OTHER
    }
  end

    def valid_registration_types
      {
        'Private Limited' => Startup::REGISTRATION_TYPE_PRIVATE_LIMITED,
        'Partnership' => Startup::REGISTRATION_TYPE_PARTNERSHIP,
        'LLP' => Startup::REGISTRATION_TYPE_LLP
      }
    end

    def product_progress_collection
      {
        'Idea' => Startup::PRODUCT_PROGRESS_IDEA,
        'Mock-up' => Startup::PRODUCT_PROGRESS_MOCKUP,
        'Prototype' => Startup::PRODUCT_PROGRESS_PROTOTYPE,
        'Private Beta' => Startup::PRODUCT_PROGRESS_PRIVATE_BETA,
        'Public Beta' => Startup::PRODUCT_PROGRESS_PUBLIC_BETA,
        'Launched' => Startup::PRODUCT_PROGRESS_LAUNCHED
      }
    end

    def incubation_locations
      {
        'Kochi' => Startup::INCUBATION_LOCATION_KOCHI,
        'Kozhikode' => Startup::INCUBATION_LOCATION_KOZHIKODE,
        'Vishakapatnam' => Startup::INCUBATION_LOCATION_VISAKHAPATNAM
      }
    end

end
