class FounderDashboardTargets extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenLevel: this.currentLevel()
    };

    this.pickFilter = this.pickFilter.bind(this);
  }

  // Current level is is maximum of available levels.
  currentLevel() {
    return Math.max.apply(null, Object.keys(this.props.levels));
  }

  targetGroups() {
    return this.props.levels[this.state.chosenLevel].target_groups;
  }

  targetCollections() {
    return this.targetGroups().map(function (targetGroup) {
      return <FounderDashboardTargetCollection key={ targetGroup.id } name={ targetGroup.name }
        description={ targetGroup.description }
        targets={ targetGroup.targets }/>
    });
  }

  filterData() {
    let levels = {};

    for (let level = 1; level <= this.currentLevel(); level++) {
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
        <FounderDashboardActionBar filter='targets' filterData={ this.filterData() } pickFilterCB={ this.pickFilter }/>
        { this.targetCollections() }
      </div>
    );
  }
}

FounderDashboardTargets.propTypes = {
  levels: React.PropTypes.object
};
