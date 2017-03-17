class FounderDashboardChores extends React.Component {
  choresForCurrentLevel() {
    return <FounderDashboardTargetCollection key='chores-current-level' name='Chores for current level'
      targets={ this.props.chores } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
  }

  choresForPreviousLevels() {
    return <FounderDashboardTargetCollection key='chores-previous-levels' name='Chores for previous levels'
      targets={ this.props.chores } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
  }

  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='chores' openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
        { this.choresForCurrentLevel() }
        { this.choresForPreviousLevels() }
      </div>
    );
  }
}

FounderDashboardChores.propTypes = {
  chores: React.PropTypes.array,
  openTimelineBuilderCB: React.PropTypes.func
};
