module ApplicationHelper
  def kaminari_page_start(paged_scope)
    ((paged_scope.current_page - 1) * paged_scope.limit_value) + 1
  end

  def kaminari_page_end(paged_scope)
    max = paged_scope.current_page * paged_scope.limit_value
    max > paged_scope.total_count ? paged_scope.total_count : max
  end
end
