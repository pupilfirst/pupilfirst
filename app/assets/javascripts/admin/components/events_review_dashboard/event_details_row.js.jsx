class EventsReviewDashboardEventDetailsRow extends React.Component {
  render() {
    return (
      <tr>
        <td colSpan='3'>
          <div>
            <strong>Description:</strong>
            <br/>
            "{this.props.eventData['description']}"
          </div>
        </td>
        <td>
          <div>
            {/*<strong>Attached Links: </strong>*/}
            { this.props.eventData['links'].map(function (link) {
              return (
                <div key={link.url + link.title}>
                  <i className="fa fa-link"/>&nbsp;<a href={link.url} target='_blank'>{link.title}</a>
                </div>
              )}
            )}
          </div>
          <div>
            { this.props.eventData['files'].map(function (file) {
                return (
                  <div key={file.file.url + file.title}>
                    <i className="fa fa-file"/>&nbsp;<a href={file.file.url} target='_blank'>{file.title}</a>
                  </div>
                )
              }
            )}
          </div>
          <div>
            <i className="fa fa-edit"/>&nbsp;
            <a href={'/admin/timeline_events/' + this.props.eventData['event_id'] + '/edit'} target='_blank'>
              Edit Event
            </a>
          </div>
        </td>
      </tr>
    )
  }
};

EventsReviewDashboardEventDetailsRow.propTypes = {
  eventData: React.PropTypes.object
};
