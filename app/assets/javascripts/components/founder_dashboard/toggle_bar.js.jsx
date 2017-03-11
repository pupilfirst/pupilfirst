class FounderDashboardToggleBar extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this)
  }

  handleClick() {
    this.props.chooseTabCB()
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
            <FounderDashboardToggleBarTab tabType='chores' pendingCount={ 20 } chooseTabCB={ this.props.chooseTabCB }
              chosen={ this.isChosenTab('chores') }/>
            <FounderDashboardToggleBarTab tabType='sessions' pendingCount={ 2 } chooseTabCB={ this.props.chooseTabCB }
              chosen={ this.isChosenTab('sessions') }/>
          </div>
        </div>
        <div className="founder-dashboard-add-event__container pull-xs-right hidden-md-up">
          <button id="#add-event-button"
            className="btn btn-md btn-secondary text-uppercase founder-dashboard-add-event__btn js-founder-dashboard__trigger-builder"
            data-toggle="modal">
            <i className="fa fa-plus"/>
          </button>
        </div>
      </div>
    );
  }
}

FounderDashboardToggleBar.propTypes = {
  selected: React.PropTypes.string,
  chooseTabCB: React.PropTypes.func
};
