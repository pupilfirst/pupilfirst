class FounderDashboardTargetsFilter extends React.Component {
  levelOptions() {
    let maxLevel = Math.max.apply(null, Object.keys(this.props.levels));
    let startLevel = 1;

    if (this.props.currentLevel == 0) {
      startLevel = 0;
    }

    let options = [];

    for (let level = startLevel; level <= maxLevel; level++) {
      options.push(<FounderDashboardTargetsFilterOption key={ 'target-filter-level-' + level } level={ level }
        name={ this.props.levels[level] } pickFilterCB={ this.props.pickFilterCB } currentLevel={ this.props.currentLevel }/>);
    }

    return options;
  }

  render() {
    return (
      <div className="btn-group filter-targets-dropdown">
        <button aria-expanded="false" aria-haspopup="true" data-toggle="dropdown" type="button"
          className="btn btn-with-icon btn-ghost-primary btn-md text-xs-left filter-targets-dropdown__button dropdown-toggle">
          <span className="p-r-1 filter-targets-dropdown__selection pull-xs-left">
            Level { this.props.chosenLevel }: { this.props.levels[this.props.chosenLevel] }
          </span>

          <span className="pull-xs-right filter-targets-dropdown__arrow"/>
        </button>

        <div className="dropdown-menu filter-targets-dropdown__menu">
          { this.levelOptions() }
        </div>
      </div>
    );
  }
}

FounderDashboardTargetsFilter.propTypes = {
  levels: React.PropTypes.object,
  chosenLevel: React.PropTypes.number,
  pickFilterCB: React.PropTypes.func,
  currentLevel: React.PropTypes.number
};
