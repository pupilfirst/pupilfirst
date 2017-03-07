class FounderDashboard extends React.Component {

  render() {
    return (
      <div className="founder-dashboard-container p-b-2">
        <FounderDashboardToggleBar/>
        <FounderDashboardTargets/>
        <FounderDashboardChores/>
        <FounderDashboardSessions/>
      </div>
    );
  }
}