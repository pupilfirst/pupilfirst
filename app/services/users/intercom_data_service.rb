module Users
  class IntercomDataService
    def initialize(user)
      @user = user
    end

    def data
      {
        name: name,
        startup: startup,
        phone: phone
      }
    end

    private

    def name
      @user.founder&.name || @user.mooc_student&.name
    end

    def startup
      @user.founder&.startup&.product_name
    end

    def phone
      @user.founder&.phone || @user.mooc_student&.phone
    end
  end
end
