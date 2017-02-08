class EventsReviewDashboardEventRow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {showDetail: false};
    this.toggleDetail = this.toggleDetail.bind(this);
    this.detailLinkText = this.detailLinkText.bind(this)
  }

  toggleDetail() {
    this.setState({showDetail: !this.state.showDetail})
  }

  detailLinkText() {
    return this.state.showDetail ? 'Hide Details' : 'View Details'
  }

  render() {
    return (
      <tr>
        <td className="col">
          <strong>Submitted by: </strong>{this.props.eventData['founder_name']}
          <br />
          <em>on {this.props.eventData['created_at']}</em>
          <br />
          { this.state.showDetail &&
          <div>
            <strong>Description:</strong>
            <br/>
            "{this.props.eventData['description']}"
          </div>
          }
        </td>
        <td className="col"><strong>Startup: </strong>{this.props.eventData['startup_name']}</td>
        <td className="col"><strong>Event on: </strong>{this.props.eventData['event_on']}</td>
        <td className="col"><strong>Target: </strong>N.A</td>
        <td className="col">
          <a onClick={ this.toggleDetail }>{this.detailLinkText()}</a>
        </td>
      </tr>
    )
  }
};

EventsReviewDashboardEventRow.propTypes = {
  eventData: React.PropTypes.object
};
