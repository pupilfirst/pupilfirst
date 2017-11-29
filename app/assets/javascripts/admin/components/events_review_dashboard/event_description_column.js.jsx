class EventsReviewDashboardEventDescriptionColumn extends React.Component {
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

  render () {
    return (
      <div>
        <strong>Description:</strong>
        <br/>
        {
          !this.state.showDescriptionEdit &&
          <div style={{width: '260px'}}>
            <div className="review-dashboard__event-description">{this.state.description}</div>
            <a className="cursor-pointer" onClick={this.toggleDescriptionForm}>Edit Description</a>
          </div>
        }
        {
          this.state.showDescriptionEdit &&
          <div>
            <textarea type="text" style={{width: '260px', height: '150px'}} value={this.state.description} onChange={this.handleDescriptionChange}/>
            <br/><br/>
            <a className="button cursor-pointer" onClick={this.saveDescription}>Save</a>
          </div>
        }
      </div>
    )
  }
};

EventsReviewDashboardEventDescriptionColumn.propTypes = {
  eventData: PropTypes.object
};
