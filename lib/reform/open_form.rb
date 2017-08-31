module Reform
  class OpenForm < OpenStruct
    def persisted?
      false
    end

    def to_key
      super
    end
  end
end
