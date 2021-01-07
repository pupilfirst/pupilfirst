module I18n
  module Backend
    class Files < I18n::Backend::Simple
      def initialize(filenames)
        @filenames = filenames
        super()
      end

      protected
      def init_translations
        load_translations(@filenames)
        @initialized = true
      end
    end
  end
end
