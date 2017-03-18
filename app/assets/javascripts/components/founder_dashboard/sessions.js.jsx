class FounderDashboardSessions extends React.Component {
  upcomingSessions() {
    return this.props.sessions.reduce(function (sessions, target) {
      if (moment(target.session_at).isAfter(moment())) {
        sessions.push(target);
      }

      return sessions;
    }, []);
  }

  pastSessions() {
    return this.props.sessions.reduce(function (sessions, target) {
      if (moment(target.session_at).isBefore(moment())) {
        sessions.push(target);
      }

      return sessions;
    }, []);
  }

  render() {
    return (
      <div>
        <FounderDashboardActionBar filter='sessions' openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
        <FounderDashboardTargetCollection key='sessions-upcoming' name='Upcoming Sessions' displayDate={ true }
          targets={ this.upcomingSessions() } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
        <FounderDashboardTargetCollection key='sessions-past' name='Past Sessions' displayDate={ true }
          targets={ this.pastSessions() } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/>
      </div>
    );
  }
}

FounderDashboardSessions.propTypes = {
  sessions: React.PropTypes.array,
  openTimelineBuilderCB: React.PropTypes.func
};
