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
      <div className="founder-dashboard-togglebar__container">
        <div className="founder-dashboard-togglebar__toggle">
          <div className="btn-group founder-dashboard-togglebar__toggle-group">
            <FounderDashboardToggleBarTab tabType='targets' pendingCount={ 0 } chooseTabCB={ this.props.chooseTabCB }
              chosen={ this.isChosenTab('targets') }/>
            <FounderDashboardToggleBarTab tabType='chores' pendingCount={ this.props.pendingChores }
              chooseTabCB={ this.props.chooseTabCB } chosen={ this.isChosenTab('chores') }/>
            <FounderDashboardToggleBarTab tabType='sessions' pendingCount={ this.props.pendingSessions }
              chooseTabCB={ this.props.chooseTabCB } chosen={ this.isChosenTab('sessions') }/>
          </div>
        </div>

        <div className="founder-dashboard-add-event__container pull-xs-right hidden-md-up">
          <button onClick={ this.openTimelineBuilder }
            className="btn btn-md btn-secondary text-uppercase founder-dashboard-add-event__btn js-founder-dashboard__trigger-builder">
            <i className="fa fa-plus" aria-hidden="true"/><span className="sr-only">Add Timeline Event</span>
          </button>
        </div>
      </div>
    );
  }
}

FounderDashboardToggleBar.propTypes = {
  selected: React.PropTypes.string,
  chooseTabCB: React.PropTypes.func,
  openTimelineBuilderCB: React.PropTypes.func,
  pendingChores: React.PropTypes.number,
  pendingSessions: React.PropTypes.number,
};
