module Types
  class UpdateSchoolStringError < Types::BaseEnum
    value 'InvalidKey', "Supplied key must be one of #{SchoolString::VALID_KEYS.join(', ')}"
    value 'InvalidLengthValue', 'Supplied value must be less than 10,000 characters in length'
  end
end
