class FounderDashboardActionBar extends React.Component {

  render() {
    return (
      <div className="founder-dashboard-actionbar__container p-x-1 m-x-auto">
        <div className="founder-dashboard-actionbar__box">
          <FounderDashboardTargetsFilter/>
          {/*<FounderDashboardChoresFilter/>
          <FounderDashboardSessionsTagSelect/>*/}
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