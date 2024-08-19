module Schools
  module Users
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, users_scope)
        @users_scope = users_scope
        super(view_context)
      end

      def users
        @users ||=
          begin
            filter_1 = filter_by_name(@users_scope)
            filter_2 = filter_by_email(filter_1)
            filter_3 = filter_by_user_type(filter_2)
            sorted = apply_sort(filter_3)
            paged = sorted.page(params[:page]).per(24)
            paged.count.zero? ? paged.page(paged.total_pages) : paged
          end
      end

      def filter
        {
          id: "school_users_filter",
          filters: [
            { key: "name", label: "Name", filterType: "Search", color: "blue" },
            {
              key: "email",
              label: "Email",
              filterType: "Search",
              color: "yellow"
            },
            {
              key: "show",
              label: "Show",
              filterType: "MultiSelect",
              values: %w[All Admins Students Coaches Authors],
              color: "green"
            }
          ],
          sorter: {
            key: "sort_by",
            default: "Name",
            options: ["Name", "Recently Seen", "First Created", "Last Created"]
          }
        }
      end

      private

      def filter_by_name(scope)
        if params[:name].present?
          scope.where("users.name ILIKE ?", "%#{params[:name]}%")
        else
          scope
        end
      end

      def filter_by_email(scope)
        if params[:email].present?
          scope.where("users.email ILIKE ?", "%#{params[:email]}%")
        else
          scope
        end
      end

      def filter_by_user_type(scope)
        case params[:show]
        when "Admins"
          scope.joins(:school_admin)
        when "Students"
          scope.joins(:students).distinct
        when "Coaches"
          scope.joins(:faculty)
        when "Authors"
          scope.joins(:course_authors).distinct
        else
          scope
        end
      end

      def apply_sort(scope)
        case params[:sort_by]
        when "Recently Seen"
          scope.order("last_seen_at DESC NULLS LAST")
        when "First Created"
          scope.order(:created_at)
        when "Last Created"
          scope.order(created_at: :desc)
        else
          scope.order(:name)
        end
      end
    end
  end
end
