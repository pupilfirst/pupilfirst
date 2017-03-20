class FounderDashboardChores extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenStatus: 'all'
    };

    this.pickFilter = this.pickFilter.bind(this);
  }

  choresForCurrentLevel() {
    return this.filteredChores().filter(function (chore) {
      return chore.level.number === this.props.currentLevel;
    }, this);
  }

  choresForPreviousLevels() {
    return this.filteredChores().filter(function (chore) {
      return chore.level.number < this.props.currentLevel;
    }, this);
  }

  pickFilter(status) {
    this.setState({chosenStatus: status});
  }

  filteredChores() {
    if (this.state.chosenStatus === 'all') {
      return this.props.chores;
    } else {
      return this.props.chores.filter(function (chore) {
        return chore.status === this.state.chosenStatus;
      }, this);
    }
  }

  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='chores' openTimelineBuilderCB={ this.props.openTimelineBuilderCB }
        chosenStatus={ this.state.chosenStatus } choresFilterCB={ this.pickFilter }/>
        <FounderDashboardTargetCollection key='chores-current-level' name='Chores for current level'
          targets={ this.choresForCurrentLevel() } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
        <FounderDashboardTargetCollection key='chores-previous-levels' name='Chores for previous levels'
          targets={ this.choresForPreviousLevels() } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
      </div>
    );
  }
}

FounderDashboardChores.propTypes = {
  currentLevel: React.PropTypes.number,
  chores: React.PropTypes.array,
  openTimelineBuilderCB: React.PropTypes.func
};
