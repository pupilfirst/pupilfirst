class EventsReviewDashboardEventDetailsRow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {description: this.props.eventData['description'], showDescriptionEdit: false};
    this.handleDescriptionChange = this.handleDescriptionChange.bind(this);
    this.saveDescription = this.saveDescription.bind(this);
    this.toggleDescriptionForm = this.toggleDescriptionForm.bind(this);
  }

  handleDescriptionChange(event) {
    this.setState({description: event.target.value});
  }

  saveDescription() {
    let description = this.state.description;
    let eventId = this.props.eventData['event_id'];
    let postUrl = '/admin/timeline_events/' + eventId + '/update_description';
    let toggleDescripitionForm = this.toggleDescriptionForm;
    $.post({
      url: postUrl,
      data: {description: description},
      success: function () {
        console.log('Description updated.');
        toggleDescripitionForm();
      },
      beforeSend: function () {
        event.target.innerHTML = 'Saving...'
      },
      error: function () {
        alert('Failed to update description. Try again')
      }
    });
  }

  toggleDescriptionForm() {
    this.setState({showDescriptionEdit: !this.state.showDescriptionEdit})
  }

  render() {
    return (
      <tr>
        <td colSpan='3'>
          <div>
            <strong>Description:</strong>
            <br/>
            {
              !this.state.showDescriptionEdit &&
              <div style={{width: '260px'}}>
                <pre style={{width: '100%', whiteSpace: 'pre-wrap'}}>"{this.state.description}"</pre>
                <a onClick={this.toggleDescriptionForm}>Edit Description</a>
              </div>
            }
            {
              this.state.showDescriptionEdit &&
              <div>
                <textarea type="text" style={{width: '260px', height: '150px'}} value={this.state.description} onChange={this.handleDescriptionChange}/>
                <br/>
                <a className="button" onClick={this.saveDescription}>Save</a>
              </div>
            }
          </div>
        </td>
        <td>
          <div>
            { this.props.eventData['links'].map(function (link) {
                return (
                  <div key={link.url + link.title}>
                    <i className="fa fa-link"/>&nbsp;<a href={link.url} target='_blank'>{link.title}</a>
                  </div>
                )
              }
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
          <br/>
          <div>
            <i className="fa fa-edit"/>&nbsp;
            <a href={'/admin/timeline_events/' + this.props.eventData['event_id'] + '/edit'} target='_blank'>
              Edit Event
            </a>
          </div>
          <div>
            <i className="fa fa-comment-o"/>&nbsp;
            <a href={this.props.eventData['feedback_url']} target='_blank'>
              Add Feedback
            </a>
          </div>
        </td>
      </tr>
    )
  }
}
;

EventsReviewDashboardEventDetailsRow.propTypes = {
  eventData: React.PropTypes.object
};
