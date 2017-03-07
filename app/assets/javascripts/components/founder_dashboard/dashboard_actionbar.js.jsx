class FounderDashboardActionBar extends React.Component {

  render() {
    return (
      <div className="founder-dashboard-actionbar__container p-x-1 m-x-auto">
        <div className="founder-dashboard-actionbar__box">
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
                All Targets
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
          <div className="pull-xs-right">
            <button id="#add-event-button" className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder hidden-sm-down m-r-1" data-toggle="modal">
              <i className="fa fa-plus"/>
              <span>Add Event</span>
            </button>
            <div className="btn-group">
              <button className="btn btn-link founder-dashboard-actionbar__show-more-menu dropdown-toggle" data-toggle="dropdown" type="button">
                <span className="founder-dashboard-actionbar__show-more-menu-dots"></span>
              </button>
              <div className="dropdown-menu filter-targets-dropdown__menu dropdown-menu-right">
                <a className="dropdown-item filter-targets-dropdown__menu-item" href="#" role="button">
                  Performance
                </a>
                <a className="dropdown-item filter-targets-dropdown__menu-item" href="#" role="button">
                  Restart
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}