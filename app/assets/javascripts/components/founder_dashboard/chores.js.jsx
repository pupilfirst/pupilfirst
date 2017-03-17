class FounderDashboardChores extends React.Component {
  choresForCurrentLevel() {
    let that = this;

    return this.props.chores.reduce(function (chores, target) {
      if (target.level.number === that.props.currentLevel) {
        chores.push(target)
      }

      return chores;
    }, []);
  }

  choresForPreviousLevels() {
    let that = this;

    return this.props.chores.reduce(function (chores, target) {
      if (target.level.number < that.props.currentLevel) {
        chores.push(target)
      }

      return chores;
    }, []);
  }

  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='chores' openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
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
