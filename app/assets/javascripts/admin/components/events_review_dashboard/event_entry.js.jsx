class EventsReviewDashboardEventEntry extends React.Component {
  render() {
    return (
      <table className="review-dashboard_event-entry-table index">
        <tbody>
          <tr>
            <td><EventsReviewDashboardEventDetailsColumn eventData={this.props.eventData}/></td>
            <td><EventsReviewDashboardEventDescriptionColumn eventData={this.props.eventData}/></td>
            <td style={{width: '600px'}}><EventsReviewDashboardEventActionsColumn eventData={this.props.eventData} removeEventCB={this.props.removeEventCB}/></td>
          </tr>
        </tbody>
      </table>
    )
  }
};

EventsReviewDashboardEventEntry.propTypes = {
  eventData: React.PropTypes.object,
  removeEventCB: React.PropTypes.func
};
