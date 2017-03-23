class FounderDashboardTargets extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenLevel: props.currentLevel
    };

    this.pickFilter = this.pickFilter.bind(this);
  }

  targetGroups() {
    return this.props.levels[this.state.chosenLevel].target_groups;
  }

  targetCollections() {
    return this.targetGroups().map(function (targetGroup) {
      return <FounderDashboardTargetCollection key={ targetGroup.id } name={ targetGroup.name }
        description={ targetGroup.description } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }
        targets={ targetGroup.targets }/>
    }, this);
  }

  filterData() {
    let levels = {};

    for (let level = 1; level <= this.props.currentLevel; level++) {
      levels[level] = this.props.levels[level].name;
    }

    return {
      levels: levels,
      chosenLevel: this.state.chosenLevel
    };
  }

  pickFilter(level) {
    this.setState({chosenLevel: level});
  }

  render() {
    return (
      <div>
        <FounderDashboardLevelupNotification/>

        <FounderDashboardActionBar filter='targets' filterData={ this.filterData() } pickFilterCB={ this.pickFilter }
          openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
        { this.targetCollections() }
      </div>
    );
  }
}

FounderDashboardTargets.propTypes = {
  currentLevel: React.PropTypes.number,
  levels: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func
};
