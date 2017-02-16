class EventsReviewDashboardEventEntry extends React.Component {
  render() {
    return (
      <table className="review-dashboard_event-entry-table">
        <tbody>
          <EventsReviewDashboardEventBasicInfoRow eventData={this.props.eventData}/>
          <EventsReviewDashboardEventDetailsRow eventData={this.props.eventData}/>
          <EventsReviewDashboardEventActionBar eventId={this.props.eventData['event_id']} removeEventCB={this.props.removeEventCB} targetId={this.props.eventData['target_id']}/>
        </tbody>
      </table>
    )
  }
};

EventsReviewDashboardEventEntry.propTypes = {
  eventData: React.PropTypes.object,
  removeEventCB: React.PropTypes.func
};
