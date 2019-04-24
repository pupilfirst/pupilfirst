module Types
  class UpdateSchoolStringError < Types::BaseEnum
    value 'InvalidKey', "Supplied key must be one of #{SchoolString::VALID_KEYS.join(', ')}"
    value 'InvalidValue', "Supplied value could not be validated against the supplied key"
    value 'InvalidLengthValue', 'Supplied value is over the allowed length for supplied key'
  end
end
