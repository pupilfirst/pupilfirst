class EventsReviewDashboard extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <table className="index_table index">
        <tbody>
        { this.props.reviewData.map(function (eventData, index) {
          return (
            <EventsReviewDashboardEventRow eventData={ eventData } key={ index } />
            )}
        )}
        </tbody>
      </table>
    )
  }
};

EventsReviewDashboard.propTypes = {
  reviewData: React.PropTypes.array
};
