class EventsReviewDashboardEventEntry extends React.Component {
  constructor(props) {
    super(props);

    this.showRubric = this.showRubric.bind(this);
  }

  showRubric() {
    let rubricVisible = this.props.rootState.reviewData[this.props.eventId]['rubricVisible'];
    return _.isBoolean(rubricVisible) && rubricVisible
  }

  render() {
    return (
      <div>
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
        {

          this.props.eventData['rubric'] && this.showRubric() &&
            <tr>
              <td colSpan={3}>
              <EventsReviewDashboardEventTargetRubric rootState={this.props.rootState}
                                                      setRootState={this.props.setRootState} rubric={this.props.eventData['rubric']}/>
              </td>
            </tr>
        }
        </tbody>
      </table>
      </div>
    )
  }
}

EventsReviewDashboardEventEntry.propTypes = {
  rootState: PropTypes.object,
  setRootState: PropTypes.func,
  eventData: PropTypes.object,
  eventId: PropTypes.number
};
