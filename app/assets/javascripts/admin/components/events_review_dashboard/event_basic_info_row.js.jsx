class EventsReviewDashboardEventBasicInfoRow extends React.Component {
  render() {
    return (
      <tr className='even'>
        <td>
          <strong>
            <a href={'/admin/timeline_events/' + this.props.eventData['event_id']} target='_blank'>
              {this.props.eventData['title']}
            </a>
          </strong>
        </td>

        <td>
          <strong>Submitted by: </strong>
          <a href={'/admin/founders/' + this.props.eventData['founder_id']} target='_blank'>
            {this.props.eventData['founder_name']}
          </a>
          &nbsp;
          (<a href={'/admin/startups/' + this.props.eventData['startup_id']} target='_blank'>{this.props.eventData['startup_name']}
        </a>)
          <br />
          <em>on {this.props.eventData['created_at']}</em>
        </td>

        <td>
          <strong>Event on: </strong>{this.props.eventData['event_on']}
        </td>

        <td><strong>Linked Target: </strong>
          <a href={'/admin/targets/' + this.props.eventData['target_id']} target='_blank'>
            {this.props.eventData['target_title']}
          </a>
        </td>
      </tr>
    )
  }
};

EventsReviewDashboardEventBasicInfoRow.propTypes = {
  eventData: React.PropTypes.object
};
