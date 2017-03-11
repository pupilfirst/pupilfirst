class FounderDashboardTargets extends React.Component {
  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='targets'/>
        <FounderDashboardTargetCollection/>
      </div>
    );
  }
}
