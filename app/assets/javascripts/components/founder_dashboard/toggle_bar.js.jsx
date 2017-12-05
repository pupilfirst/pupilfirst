class FounderDashboardToggleBar extends React.Component {
  constructor(props) {
    super(props);

    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
  }

  openTimelineBuilder() {
    this.props.openTimelineBuilderCB()
  }

  isChosenTab(tab) {
    return tab === this.props.selected;
  }

  render() {
    return (
      <div className="founder-dashboard-togglebar__container d-flex justify-content-between">
        <div className="founder-dashboard-togglebar__toggle">
          <div className="btn-group founder-dashboard-togglebar__toggle-group">
            <FounderDashboardToggleBarTab tabType='targets' pendingCount={0} chooseTabCB={this.props.chooseTabCB}
              chosen={this.isChosenTab('targets')}/>
            <FounderDashboardToggleBarTab tabType='sessions' pendingCount={this.props.pendingSessions}
              chooseTabCB={this.props.chooseTabCB} chosen={this.isChosenTab('sessions')}/>
          </div>
        </div>

        {
          this.props.currentLevel != 0 &&
          <div className="founder-dashboard-add-event__container d-md-none">
            <button onClick={this.openTimelineBuilder}
              className="btn btn-md btn-secondary text-uppercase founder-dashboard-add-event__btn js-founder-dashboard__trigger-builder">
              <i className="fa fa-plus" aria-hidden="true"/><span className="sr-only">Add Timeline Event</span>
            </button>
          </div>
        }
      </div>
    );
  }
}

FounderDashboardToggleBar.propTypes = {
  selected: PropTypes.string,
  chooseTabCB: PropTypes.func,
  openTimelineBuilderCB: PropTypes.func,
  pendingSessions: PropTypes.number,
  currentLevel: PropTypes.number
};
