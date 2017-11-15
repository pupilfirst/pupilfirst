class EventsReviewDashboardEventEntry extends React.Component {
  render() {
    return (
      <table className="review-dashboard__event-entry-table index">
        <tbody>
        <tr>
          <td><EventsReviewDashboardEventDetailsColumn eventData={this.props.eventData}/></td>
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
};

EventsReviewDashboardEventEntry.propTypes = {
  rootState: React.PropTypes.object,
  setRootState: React.PropTypes.func,
  eventData: React.PropTypes.object
};
