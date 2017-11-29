class EventsReviewDashboardEventEntry extends React.Component {
  render() {
    return (
      <table className="review-dashboard__event-entry-table index">
        <tbody>
        <tr>
          <td>
            <EventsReviewDashboardEventDetailsColumn eventId={this.props.eventId} rootState={this.props.rootState}
              setRootState={this.props.setRootState}/>
          </td>
          <td><EventsReviewDashboardEventDescriptionColumn eventData={this.props.eventData}/></td>
          <td style={{width: '600px'}}>
            <EventsReviewDashboardEventActionsColumn rootState={this.props.rootState}
              setRootState={this.props.setRootState} eventData={this.props.eventData}/>
          </td>
        </tr>
        </tbody>
      </table>
    )
  }
}

EventsReviewDashboardEventEntry.propTypes = {
  rootState: PropTypes.object,
  setRootState: PropTypes.func,
  eventData: PropTypes.object,
  eventId: PropTypes.number
};
