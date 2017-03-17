class FounderDashboardSessions extends React.Component {
  upcomingSessions() {
    return <FounderDashboardTargetCollection key='sessions-upcoming' name='Upcoming Sessions'
      targets={ this.props.sessions } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
  }

  pastSessions() {
    return <FounderDashboardTargetCollection key='sessions-past' name='Past Sessions'
      targets={ this.props.sessions } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
  }

  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='sessions' openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
        { this.upcomingSessions() }
        { this.pastSessions() }
      </div>
    );
  }
}

FounderDashboardSessions.propTypes = {
  sessions: React.PropTypes.array,
  openTimelineBuilderCB: React.PropTypes.func
};
