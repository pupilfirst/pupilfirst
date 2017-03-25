class FounderDashboardTargetCollection extends React.Component {
  targets() {
    if (this.props.targets.length < 1) {
      return (
        <div className="founder-dashboard-target-noresult text-xs-center p-y-2">
          <img className="founder-dashboard-target-noresult__icon m-x-auto"
            src={'/assets/founders/dashboard/no-results-icon.svg'}/>
          <h4 className="m-t-1 font-regular">No results to display!</h4>
        </div>
      )
    } else {
      return this.props.targets.map(function (target) {
        return <FounderDashboardTarget key={ target.id } target={ target }
        openTimelineBuilderCB={ this.props.openTimelineBuilderCB } displayDate={ this.props.displayDate }/>
      }, this);
    }
  }

  render() {
    return (
      <div className="founder-dashboard-target-group__container p-x-1 m-x-auto">
        <div className="founder-dashboard-target-group__box">
          <div className="founder-dashboard-target-group__header text-xs-center">
            <div className="founder-dashboard-target-group__milestone-label text-uppercase font-semibold">
              Milestone Targets
            </div>
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
  displayDate: React.PropTypes.bool
};
