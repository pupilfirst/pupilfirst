class FounderDashboardChoresFilter extends React.Component {

  render() {
    return (
      <div className="btn-group filter-targets-dropdown">
        <button className="btn btn-with-icon btn-ghost-primary btn-md text-xs-left filter-targets-dropdown__button dropdown-toggle" aria-expanded="false" aria-haspopup="true" data-toggle="dropdown" type="button">
          <span className="filter-targets-dropdown__icon">
            {/*- if instance_variable_defined?(:@filtered_targets)
              i.fa class=TargetDecorator.fa_icon_for_filter(params[:filter])
            - else
              i.fa.fa-filter*/}
            <i className="fa fa-sliders"/>
          </span>
          <span className="p-r-1">
           {/*- if params[:filter].present?
             | #{ t("dashboard.show.target_filters.#{params[:filter]}.filter_text") }
           - else
             | All Targets*/}
            All Chores
          </span>
          <span className="pull-xs-right filter-targets-dropdown__arrow"></span>
        </button>

        <div className="dropdown-menu filter-targets-dropdown__menu">
          {/*- selected_filter =  instance_variable_defined?(:@filtered_targets) ? params[:filter] : 'all_targets'
          - Founders::TargetsFilterService.filters_except(selected_filter).each do |filter|
            a.dropdown-item.filter-targets-dropdown__menu-item href=dashboard_founder_path(filter: filter) role="button"
              span.filter-targets-dropdown__menu-item-icon
                i.fa class=TargetDecorator.fa_icon_for_filter(filter)
              | #{ t("dashboard.show.target_filters.#{filter}.filter_text") }*/}
          <a className="dropdown-item filter-targets-dropdown__menu-item" href="#" role="button">
            <span className="filter-targets-dropdown__menu-item-icon">
              <i className="fa fa-line-chart"/>
            </span>
            Level 1: Idea Discovery
          </a>
        </div>
      </div>
    );
  }
}
