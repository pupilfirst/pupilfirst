class FounderDashboardSessions extends React.Component {
  upcomingSessions() {
    return <FounderDashboardTargetCollection key='sessions-upcoming' name='Upcoming Sessions'
      targets={ this.props.sessions }/>
  }

  pastSessions() {
    return <FounderDashboardTargetCollection key='sessions-past' name='Past Sessions'
      targets={ this.props.sessions }/>
  }

  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='sessions'/>
        { this.upcomingSessions() }
        { this.pastSessions() }
      </div>
    );
  }
}

FounderDashboardSessions.propTypes = {
  sessions: React.PropTypes.array
};
