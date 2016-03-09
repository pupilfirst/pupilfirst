module IncubationHelper
  def valid_gender_values
    {
      'Male' => Founder::GENDER_MALE,
      'Female' => Founder::GENDER_FEMALE,
      'Other' => Founder::GENDER_OTHER
    }
  end

  def valid_registration_types
    {
      'Private Limited' => Startup::REGISTRATION_TYPE_PRIVATE_LIMITED,
      'Partnership' => Startup::REGISTRATION_TYPE_PARTNERSHIP,
      'Limited Liability Partnership' => Startup::REGISTRATION_TYPE_LLP
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
end
