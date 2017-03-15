class FounderDashboardTargetsFilter extends React.Component {
  levelOptions() {
    let maxLevel = Math.max.apply(null, Object.keys(this.props.levels));

    let options = [];

    for (let level = 1; level <= maxLevel; level++) {
      options.push(<FounderDashboardTargetsFilterOption key={ 'target-filter-level-' + level } level={ level }
        name={ this.props.levels[level] } pickFilterCB={ this.props.pickFilterCB }/>);
    }

    return options;
  }

  render() {
    return (
      <div className="btn-group filter-targets-dropdown">
        <button aria-expanded="false" aria-haspopup="true" data-toggle="dropdown" type="button"
          className="btn btn-with-icon btn-ghost-primary btn-md text-xs-left filter-targets-dropdown__button dropdown-toggle">
          <span className="filter-targets-dropdown__icon">
            <i className="fa fa-sliders"/>
          </span>

          <span className="p-r-1">
            { this.props.levels[this.props.chosenLevel] }
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
  pickFilterCB: React.PropTypes.func
};
