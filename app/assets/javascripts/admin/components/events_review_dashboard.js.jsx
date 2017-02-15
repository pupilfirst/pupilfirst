class EventsReviewDashboard extends React.Component {
  constructor(props) {
    super(props);
    this.removeEventCB = this.removeEventCB.bind(this);
    this.state = {reviewData: this.props.reviewData};
  }

  removeEventCB(eventID) {
    console.log('Removing event with id ' + eventID);
    let reviewData = this.state.reviewData;
    delete(reviewData[eventID]);
    this.setState({reviewData: reviewData});
  }

  render() {
    return (
      <div>
        <h3> Total events pending review: {Object.keys(this.state.reviewData).length}</h3>
        <table>
          <tbody><tr><td>
          { Object.keys(this.state.reviewData).map(function (key) {
            return (
              <EventsReviewDashboardEventEntry eventData={ this.state.reviewData[key] } key={ key } removeEventCB={this.removeEventCB}/>
              )}, this
          )}
          </td></tr></tbody>
        </table>
      </div>
    )
  }
};

EventsReviewDashboard.propTypes = {
  reviewData: React.PropTypes.object
};
