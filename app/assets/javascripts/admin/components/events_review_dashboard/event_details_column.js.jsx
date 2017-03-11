class EventsReviewDashboardEventDetailsColumn extends React.Component {
  render () {
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
          (<a href={'/admin/startups/' + this.props.eventData['startup_id']} target='_blank'>{this.props.eventData['startup_name']}
          </a>)
          <br />
          <em>on {this.props.eventData['created_at']}</em>
        </div>
        <br/>
        <div>
          <strong>Event on: </strong>{this.props.eventData['event_on']}
        </div>
        <br/>
        <div>
          <strong>Linked Target: </strong>
          { this.props.eventData['target_id'] &&
          <a href={'/admin/targets/' + this.props.eventData['target_id']} target='_blank'>
            {this.props.eventData['target_title']}
          </a>
          }
          { !this.props.eventData['target_id'] &&
          <span>None</span>
          }
        </div>
        <br/>
        { this.props.eventData['improvement_of'] &&
        <div>
          <strong>Improvement of: </strong>
          <a href={'/admin/timeline_events/' + this.props.eventData['improvement_of']['id']} target='_blank'>
            {this.props.eventData['improvement_of_title'] + ' (' + this.props.eventData['improvement_of']['verified_status'] + ')'}
          </a>
          <br/>
        </div>
        }
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
                <div key={file.id + file.title}>
                  <i className="fa fa-file"/>&nbsp;<a href={'/admin/timeline_events/' + file.timeline_event_id + '/get_attachment?timeline_event_file_id=' + file.id} target='_blank'>{file.title}</a>
                </div>
              )
            }
          )}
        </div>
        { this.props.eventData['image'] &&
        <div>
          <i className="fa fa-file-image-o"/>&nbsp;<a href={'/admin/timeline_events/' + this.props.eventData['event_id'] + '/get_image'} target='_blank'>{this.props.eventData['image']}</a>
        </div>
        }
      </div>
    )
  }
};

EventsReviewDashboardEventDetailsColumn.propTypes = {
  eventData: React.PropTypes.object
};
