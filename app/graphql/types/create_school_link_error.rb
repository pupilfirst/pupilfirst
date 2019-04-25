module Types
  class CreateSchoolLinkError < Types::BaseEnum
    value 'InvalidKind', 'Supplied kind must be one of "header", "footer", or "social"'
    value 'InvalidLengthTitle', 'Supplied title must be between 1 and 24 characters in length'
    value 'InvalidUrl', 'Supplied URL is not valid'
    value 'BlankTitle', 'Title is required for "header" and "footer" links'
  end
end
