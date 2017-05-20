class FounderDashboardActionBar extends React.Component {
  constructor(props) {
    super(props);

    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
  }

  openTimelineBuilder() {
    if (this.props.currentLevel == 0){
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
      <div className="founder-dashboard-actionbar__container p-x-1 m-x-auto">
        <div className="founder-dashboard-actionbar__box clearfix">
          { this.props.filter === 'targets' &&
          <FounderDashboardTargetsFilter levels={ this.props.filterData.levels } pickFilterCB={ this.props.pickFilterCB } chosenLevel={ this.props.filterData.chosenLevel } currentLevel={ this.props.currentLevel }/>
          }

          { this.props.filter === 'chores' &&
          <FounderDashboardChoresFilter pickFilterCB={ this.props.choresFilterCB } chosenStatus={ this.props.chosenStatus }/>
          }

          { this.props.filter === 'sessions' &&
          <FounderDashboardSessionsTagSelect tags={ this.props.filterData.tags }
            chooseTagsCB={ this.props.pickFilterCB }/>
          }

          <div className="pull-xs-right">
            <button onClick={ this.openTimelineBuilder }
              className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder hidden-sm-down m-r-1 js-founder-dashboard__action-bar-add-event-button">
              <i className="fa fa-plus" aria-hidden="true"/>
              <span>Add Event</span>
            </button>

            { this.props.currentLevel != 0 &&
              <div className="btn-group">
                <button className="btn btn-link founder-dashboard-actionbar__show-more-menu dropdown-toggle"
                        data-toggle="dropdown" type="button">
                  <span className="founder-dashboard-actionbar__show-more-menu-dots"/>
                </button>

                <div className="dropdown-menu filter-targets-dropdown__menu dropdown-menu-right">
                  <a className="dropdown-item filter-targets-dropdown__menu-item" data-toggle="modal"
                     data-target="#performance-overview-modal" role="button">
                    Performance
                  </a>

                  <a className="dropdown-item filter-targets-dropdown__menu-item" data-toggle="modal"
                     data-target="#startup-restart-form" role="button">
                    Pivot
                  </a>
                </div>
              </div>
            }
          </div>
        </div>
      </div>
    );
  }
}

FounderDashboardActionBar.propTypes = {
  filter: React.PropTypes.string,
  filterData: React.PropTypes.object,
  pickFilterCB: React.PropTypes.func,
  openTimelineBuilderCB: React.PropTypes.func,
  currentLevel: React.PropTypes.number
};
