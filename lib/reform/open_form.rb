module Reform
  class OpenForm < OpenStruct
    def persisted?
      false
    end
  end
end
