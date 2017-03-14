class FounderDashboardTargetCollection extends React.Component {
  targets() {
    return this.props.targets.map(function(target) {
      return <FounderDashboardTarget key={ target.id }/>
    })
  }

  render() {
    return (
      <div className="founder-dashboard-target-group__container p-x-1 m-x-auto">
        <div className="founder-dashboard-target-group__box">
          <div className="founder-dashboard-target-group__header text-xs-center">
            <h4 className="brand-primary font-regular">
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
};
