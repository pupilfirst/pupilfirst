class FounderDashboardTargetCollection extends React.Component {
  targets() {
    if (this.props.targets.length < 1) {
      return (
        <div className="text-xs-center m-b-2">No results to display!</div>
      )
    } else {
      return this.props.targets.map(function (target) {
        return <FounderDashboardTarget key={ target.id } target={ target }
        openTimelineBuilderCB={ this.props.openTimelineBuilderCB } displayDate={ this.props.displayDate }/>
      }, this);
    }
  }

  containerClasses() {
    let classes = 'founder-dashboard-target-group__container p-x-1 m-x-auto';

    if (this.props.finalCollection) {
      classes += ' founder-dashboard-target-group__container--final';
    }

    return classes;
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        <div className="founder-dashboard-target-group__box">
          <div className="founder-dashboard-target-group__header text-xs-center">
            { this.props.milestone &&
            <div className="founder-dashboard-target-group__milestone-label text-uppercase font-semibold">
              Milestone Targets
            </div>
            }

            <h4 className="brand-primary font-regular m-t-2">
              { this.props.name }
            </h4>

            <div className="founder-dashboard-target-group__header-info">
              { this.props.description }
            </div>
          </div>

          { this.targets() }
        </div>
      </div>
    );
  }
}

FounderDashboardTargetCollection.propTypes = {
  name: React.PropTypes.string,
  description: React.PropTypes.string,
  targets: React.PropTypes.array,
  openTimelineBuilderCB: React.PropTypes.func,
  displayDate: React.PropTypes.bool,
  milestone: React.PropTypes.bool,
  finalCollection: React.PropTypes.bool
};

FounderDashboardTargetCollection.defaultProps = {
  milestone: false,
  finalCollection: false
};
