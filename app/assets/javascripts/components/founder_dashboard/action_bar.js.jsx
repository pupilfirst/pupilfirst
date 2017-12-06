class FounderDashboardActionBar extends React.Component {
  constructor(props) {
    super(props);

    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
  }

  openTimelineBuilder() {
    if (this.props.currentLevel == 0) {
      $('.js-founder-dashboard__action-bar-add-event-button').popover('show');

      setTimeout(function () {
        $('.js-founder-dashboard__action-bar-add-event-button').popover('hide');
      }, 3000);
    } else {
      this.props.openTimelineBuilderCB();
    }
  }

  componentDidMount() {
    if (this.props.currentLevel == 0) {
      $('.js-founder-dashboard__action-bar-add-event-button').popover({
        title: 'Feature Locked!',
        content: 'This feature is not available for level zero founders.',
        html: true,
        placement: 'bottom',
        trigger: 'manual'
      });
    }
  }

  componentWillUnmount() {
    $('.js-founder-dashboard__action-bar-add-event-button').popover('dispose');
  }

  render() {
    return (
      <div className="founder-dashboard-actionbar__container px-2 mx-auto">
        <div className="founder-dashboard-actionbar__box d-flex justify-content-between">
          {this.props.filter === 'targets' &&
          <FounderDashboardTargetsFilter levels={this.props.filterData.levels} pickFilterCB={this.props.pickFilterCB}
            chosenLevel={this.props.filterData.chosenLevel} currentLevel={this.props.currentLevel}/>
          }

          {this.props.filter === 'sessions' &&
          <FounderDashboardSessionsTagSelect tags={this.props.filterData.tags}
            chooseTagsCB={this.props.pickFilterCB}/>
          }

          <div className="d-flex">
            <button onClick={this.openTimelineBuilder}
              className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder d-none d-md-block mr-2 js-founder-dashboard__action-bar-add-event-button">
              <i className="fa fa-plus-circle" aria-hidden="true"/>
              <span>Add Event</span>
            </button>

            <div className="btn-group">
              <button className="btn btn-link founder-dashboard-actionbar__show-more-menu dropdown-toggle"
                data-toggle="dropdown" type="button">
                <span className="founder-dashboard-actionbar__show-more-menu-dots"/>
              </button>

              <div className="dropdown-menu filter-targets-dropdown__menu dropdown-menu-right">
                {this.props.currentLevel !== 0 &&
                <span>
                    <a className="dropdown-item filter-targets-dropdown__menu-item" data-toggle="modal"
                      data-target="#performance-overview-modal" role="button">
                      Performance
                    </a>

                    <a className="dropdown-item filter-targets-dropdown__menu-item" data-toggle="modal"
                      data-target="#startup-restart-form" role="button">
                    Pivot
                    </a>
                  </span>
                }
                <a id="filter-targets-dropdown__tour-button"
                  className="dropdown-item filter-targets-dropdown__menu-item" role="button">
                  Take a Tour
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

FounderDashboardActionBar.propTypes = {
  filter: PropTypes.string,
  filterData: PropTypes.object,
  pickFilterCB: PropTypes.func,
  openTimelineBuilderCB: PropTypes.func,
  currentLevel: PropTypes.number
};
