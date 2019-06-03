module Types
  class CreateTargetErrors < Types::BaseEnum
    value 'TitleBlank', "Target title cannot be blank"
    value 'TargetGroupIdBlank', "Target group id cannot be blank"
  end
end
