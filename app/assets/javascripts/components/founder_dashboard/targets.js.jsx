class FounderDashboardTargets extends React.Component {
  targetCollections() {
    return this.props.targetGroups.map(function (targetGroup) {
      return <FounderDashboardTargetCollection key={ targetGroup.id } name={ targetGroup.name }
        description={ targetGroup.description }
        targets={ targetGroup.targets }/>
    });
  }

  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='targets'/>
        { this.targetCollections() }
      </div>
    );
  }
}

FounderDashboardTargets.propTypes = {
  targetGroups: React.PropTypes.array
};
