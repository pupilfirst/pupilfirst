class EventsReviewDashboardEventDetailsColumn extends React.Component {
  constructor(props) {
    super(props);

    const eventData = props.rootState.reviewData[props.eventId];

    this.state = {
      linkedTarget: {id: eventData['target_id'], title: eventData['target_title']},
      targetLinkingInProgress: false
    };

    this.linkTarget = this.linkTarget.bind(this);
    this.targetInputId = this.targetInputId.bind(this);
  }

  isTargetLinked() {
    return _.isNumber(this.state.linkedTarget.id);
  }

  componentWillReceiveProps(nextProps) {
    const eventData = nextProps.rootState.reviewData[nextProps.eventId];

    // debugger;

    if (this.state.linkedTarget.id !== eventData.target_id) {
      this.setState({
        linkedTarget: {
          id: eventData.target_id,
          title: eventData.target_title
        }
      });
    }
  }

  componentDidMount() {
    const linkTargetInput = $(this.targetInputId());
    linkTargetInput.select2({placeholder: "Select Target"});
    this.activateTargetSelect2()
  }

  activateTargetSelect2() {
    const targetSelect = $('#' + this.targetInputId());

    targetSelect.select2({
      width: '100%',
      minimumInputLength: 3,
      ajax: {
        url: '/targets/select2_search',
        dataType: 'json',
        delay: 500,
        data: function (params) {
          return {
            q: params.term
          }
        },
        processResults: function (data) {
          return {results: data}
        },
        cache: true
      }
    });
  }

  linkTarget() {
    const eventId = this.props.eventId;
    const inputId = '#' + this.targetInputId();
    const selectedTargetId = $(inputId).val();
    const selectedTargetName = $(inputId).find(":selected").text();
    const postUrl = '/admin/timeline_events/' + eventId + '/link_target?ajax=true';
    const that = this;

    this.setState({targetLinkingInProgress: true}, function () {
      $.post({
        url: postUrl,
        data: {target_id: selectedTargetId},
        success: function () {
          console.log('Linked target to timeline event.');

          new PNotify({
            type: 'success',
            title: 'Linking complete',
            text: 'Event ' + eventId + ' has been linked to target with ID ' + selectedTargetId + '.'
          });

          that.updateTargetLinking(selectedTargetId, selectedTargetName)

          // TODO: Reset the input form for target selection.
        },
        error: function () {
          alert('Failed to link target. Try again.')
        }
      }).always(function () {
        that.setState({targetLinkingInProgress: false})
      });
    });
  }

  updateTargetLinking(targetId, targetName) {
    const reviewDataClone = _.cloneDeep(this.props.rootState.reviewData);
    const eventData = reviewDataClone[this.props.eventId];
    eventData.target_id = parseInt(targetId);
    eventData.target_title = targetName;

    this.props.setRootState({reviewData: reviewDataClone});
  }

  targetInputId() {
    return "event-details-column__target-input-" + this.props.eventId;
  }

  linkTargetLabel() {
    return this.isTargetLinked() ? 'Link another Target:' : 'Link a Target:';
  }

  linkTargetButtonText() {
    return this.state.targetLinkingInProgress ? 'Linking...' : 'Link Target';
  }

  linkTargetButtonClasses() {
    const classes = 'margin-top-10 button cursor-pointer';

    if (this.state.targetLinkingInProgress) {
      return classes + ' disabled';
    } else {
      return classes;
    }
  }

  render() {
    const eventData = this.props.rootState.reviewData[this.props.eventId];

    return (
      <div>
        <div>
          <a href={'/admin/timeline_events/' + this.props.eventId} target='_blank'>
            <strong>{eventData['title']}</strong>
          </a>
        </div>
        <br/>
        <div>
          <strong>Submitted by: </strong>
          <a href={'/admin/founders/' + eventData['founder_id']} target='_blank'>
            {eventData['founder_name']}
          </a>
          &nbsp;
          (<a href={'/admin/startups/' + eventData['startup_id']}
          target='_blank'>{eventData['startup_name']}
        </a>)
          <br/>
          <em>on {eventData['created_at']}</em>
        </div>
        <br/>
        <div>
          <strong>Event on: </strong>{eventData['event_on']}
        </div>
        <br/>
        <div>
          <div>
            <strong>Linked Target: </strong>
            {this.isTargetLinked() &&
            <a href={'/admin/targets/' + this.state.linkedTarget.id} target='_blank'>
              {this.state.linkedTarget.title}
            </a>
            }
            {!this.isTargetLinked() && <em>None</em>}
          </div>

          <div>
            <strong>{this.linkTargetLabel()}</strong><br/>
            <select id={this.targetInputId()}/>
          </div>

          <a className={this.linkTargetButtonClasses()} onClick={this.linkTarget}>{this.linkTargetButtonText()}</a>
        </div>
        <br/>
        {eventData['improvement_of'] &&
        <div>
          <strong>Improvement of: </strong>
          <a href={'/admin/timeline_events/' + eventData['improvement_of']['id']} target='_blank'>
            {eventData['improvement_of_title'] + ' (' + eventData['improvement_of']['status'] + ')'}
          </a>
          <br/>
        </div>
        }
        <div>
          {eventData['links'].map(function (link) {
              return (
                <div key={link.url + link.title}>
                  <i className="fa fa-link"/>&nbsp;<a href={link.url} target='_blank'>{link.title}</a>
                </div>
              )
            }
          )}
        </div>
        <div>
          {eventData['files'].map(function (file) {
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
        {eventData['image'] &&
        <div>
          <i className="fa fa-file-image-o"/>&nbsp;<a
          href={'/admin/timeline_events/' + this.props.eventId + '/get_image'}
          target='_blank'>{eventData['image']}</a>
        </div>
        }
      </div>
    )
  }
}

EventsReviewDashboardEventDetailsColumn.propTypes = {
  rootState: React.PropTypes.object,
  setRootState: React.PropTypes.func,
  eventId: React.PropTypes.number
};
