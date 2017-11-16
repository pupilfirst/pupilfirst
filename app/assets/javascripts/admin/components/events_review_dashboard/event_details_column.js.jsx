class EventsReviewDashboardEventDetailsColumn extends React.Component {
  constructor(props) {
    super(props);
    this.state = {linkedTarget: this.props.eventData['target_id']};
    this.linkTarget = this.linkTarget.bind(this);
    this.targetInputId = this.targetInputId.bind(this);
  }

  componentDidMount() {
    const linkTargetInput = $(this.targetInputId());
    linkTargetInput.select2({placeholder: "Select Target"});
  }

  linkTarget() {
    const eventId = this.props.eventData['event_id'];
    const inputId = '#' + this.targetInputId();
    const selectedTarget = $(inputId).val();
    const postUrl = '/admin/timeline_events/' + eventId + '/link_target';

    $.post({
      url: postUrl,
      data: {target_id: selectedTarget},
      success: function () {
        console.log('Linked target to timeline event.');
      },
      beforeSend: function () {
        event.target.innerHTML = 'Linking...'
      },
      error: function () {
        alert('Failed to link target. Try again')
      }
    });
  }

  selectOptions() {
    return (<select id={this.targetInputId()}>
      { this.props.liveTargets.map(function (targetData) {
        const id = Object.keys(targetData)[0];
        const title = targetData[id];
        return <option value={id} key={id}>{title}</option>
      }, this)}
    </select>)
  }

  targetInputId() {
    return "event-details-column__target-input-" + this.props.eventData['event_id'];
  }

  render() {
    return (
      <div>
        <div>
          <a href={'/admin/timeline_events/' + this.props.eventData['event_id']} target='_blank'>
            <strong>{this.props.eventData['title']}</strong>
          </a>
        </div>
        <br/>
        <div>
          <strong>Submitted by: </strong>
          <a href={'/admin/founders/' + this.props.eventData['founder_id']} target='_blank'>
            {this.props.eventData['founder_name']}
          </a>
          &nbsp;
          (<a href={'/admin/startups/' + this.props.eventData['startup_id']}
              target='_blank'>{this.props.eventData['startup_name']}
        </a>)
          <br/>
          <em>on {this.props.eventData['created_at']}</em>
        </div>
        <br/>
        <div>
          <strong>Event on: </strong>{this.props.eventData['event_on']}
        </div>
        <br/>
        <div>
          {this.state.linkedTarget &&
          <div>
          <strong>Linked Target: </strong>
          <a href={'/admin/targets/' + this.props.eventData['target_id']} target='_blank'>
            {this.props.eventData['target_title']}
          </a>
          </div>
          }
          {!this.state.linkedTarget &&
            <div>
              <strong>Link a Target: </strong> <br/>
              { this.selectOptions() }
              <select id={this.targetInputId()}>
                { this.props.liveTargets.map(function (targetData) {
                  id = Object.keys(targetData)[0];
                  return <option value={targetData.key}>{targetData.title}</option>
                }, this)}
              </select> <br/><br/>
              <a className="button cursor-pointer" onClick={this.linkTarget}>Link Target</a>
            </div>
          }
        </div>
        <br/>
        {this.props.eventData['improvement_of'] &&
        <div>
          <strong>Improvement of: </strong>
          <a href={'/admin/timeline_events/' + this.props.eventData['improvement_of']['id']} target='_blank'>
            {this.props.eventData['improvement_of_title'] + ' (' + this.props.eventData['improvement_of']['status'] + ')'}
          </a>
          <br/>
        </div>
        }
        <div>
          {this.props.eventData['links'].map(function (link) {
              return (
                <div key={link.url + link.title}>
                  <i className="fa fa-link"/>&nbsp;<a href={link.url} target='_blank'>{link.title}</a>
                </div>
              )
            }
          )}
        </div>
        <div>
          {this.props.eventData['files'].map(function (file) {
              return (
                <div key={file.id + file.title}>
                  <i className="fa fa-file"/>&nbsp;<a
                  href={'/admin/timeline_events/' + file.timeline_event_id + '/get_attachment?timeline_event_file_id=' + file.id}
                  target='_blank'>{file.title}</a>
                </div>
              )
            }
          )}
        </div>
        {this.props.eventData['image'] &&
        <div>
          <i className="fa fa-file-image-o"/>&nbsp;<a
          href={'/admin/timeline_events/' + this.props.eventData['event_id'] + '/get_image'}
          target='_blank'>{this.props.eventData['image']}</a>
        </div>
        }
      </div>
    )
  }
}

EventsReviewDashboardEventDetailsColumn.propTypes = {
  eventData: React.PropTypes.object,
  liveTargets: React.PropTypes.array
};
