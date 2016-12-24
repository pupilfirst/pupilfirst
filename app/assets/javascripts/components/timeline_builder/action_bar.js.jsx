const TimelineBuilderActionBar = React.createClass({
  propTypes: {
    formClickedCB: React.PropTypes.func,
    currentForm: React.PropTypes.string,
    submitCB: React.PropTypes.func,
    timelineEventTypes: React.PropTypes.object,
    coverImage: React.PropTypes.object,
    addDataCB: React.PropTypes.func,
    imageButtonKey: React.PropTypes.string,
    selectedDate: React.PropTypes.string,
    submissionProgress: React.PropTypes.number,
    attachmentAllowed: React.PropTypes.bool,
    dateError: React.PropTypes.bool,
    eventTypeError: React.PropTypes.bool,
    resetErrorsCB: React.PropTypes.func
  },

  getInitialState: function () {
    return {
      attachmentAllowed: this.props.attachmentAllowed,
      dateError: false,
      eventTypeError: false
    };
  },

  componentWillReceiveProps: function(newProps) {
    let newDateError = this.state.dateError;
    let newEventTypeError = this.state.eventTypeError;
    if (newDateError != newProps.dateError) {
      newDateError = newProps.dateError;
    }
    if (newEventTypeError != newProps.eventTypeError) {
      newEventTypeError = newProps.eventTypeError;
    }

    this.setState({
      attachmentAllowed: newProps.attachmentAllowed,
      dateError: newDateError,
      eventTypeError: newEventTypeError
    });
  },

  componentDidUpdate: function () {
    if (this.state.dateError) {
      $('.date-of-event').popover('show');
    } else {
      $('.date-of-event').popover('hide');
    };
    if (this.state.eventTypeError) {
      $('.timeline-builder__timeline_event_type').popover('show');
    } else {
      $('.timeline-builder__timeline_event_type').popover('hide');
    };
  },

  formLinkClasses: function (type) {
    let classes = '';

    if (type == 'link') {
      classes = 'timeline-builder__upload-section-tab link-upload' + (this.state.attachmentAllowed ? '' : ' action-tab-disabled')
    } else if (type == 'file') {
      classes = 'timeline-builder__upload-section-tab file-upload'+ (this.state.attachmentAllowed ? '' : ' action-tab-disabled')
    } else {
      classes = 'timeline-builder__upload-section-tab date-of-event'
    }

    if (this.props.currentForm == type) {
      classes += ' timeline-builder__active-tab';
    }

    return classes;
  },

  showLinkForm: function () {
    if (this.state.attachmentAllowed) {
      this.props.formClickedCB('link');
    }
  },

  showFileForm: function () {
    if (this.state.attachmentAllowed) {
      this.props.formClickedCB('file');
    }
  },

  showDateForm: function () {
    if (this.state.dateError) {
      this.props.resetErrorsCB();
    }
    this.props.formClickedCB('date');
  },

  timelineEventTypes: function () {
    Object.keys(this.props.timelineEventTypes).forEach(function (role, _index) {

    });
  },

  dateLabel: function () {
    if (this.props.selectedDate != null) {
      let date = moment(this.props.selectedDate, 'YYYY-MM-DD');
      return date.format('MMM D');
    } else {
      return 'Date';
    }
  },

  handleTimelineEventTypeChange: function (event) {
    let timelineEventTypeSelect = $(event.target);

    if (timelineEventTypeSelect.val().length > 0) {
      this.props.addDataCB('timeline_event_type', {id: timelineEventTypeSelect.val()})
    }

    if (this.state.eventTypeError) {
      this.props.resetErrorsCB();
    }
  },

  render: function () {
    return (
      <div className="timeline-builder__submit-tabs">
        <div className="timeline-builder__upload-section">
          <TimelineBuilderImageButton key={ this.props.imageButtonKey } coverImage={ this.props.coverImage } addDataCB={ this.props.addDataCB }/>
          <div className={ this.formLinkClasses('link') } onClick={ this.showLinkForm }>
            <i className="timeline-builder__upload-section-icon fa fa-link"/>
            <span className="timeline-builder__tab-label">Link</span>
          </div>
          <div className={ this.formLinkClasses('file') } onClick={ this.showFileForm }>
            <i className="timeline-builder__upload-section-icon fa fa-file-text-o"/>
            <span className="timeline-builder__tab-label">File</span>
          </div>
          <div className={ this.formLinkClasses('date') } onClick={ this.showDateForm } data-toggle="popover" data-title="Date Missing!" data-content="Please select a date for the event." data-placement="bottom">
            <i className="timeline-builder__upload-section-icon fa fa-calendar"/>
            <span className="timeline-builder__tab-label">{ this.dateLabel() }</span>
          </div>
        </div>

        <div className="timeline-builder__select-section">
          <div className="timeline-builder__select-section-tab timeline-builder__type-of-event-select">
            <select className="form-control timeline-builder__timeline_event_type" defaultValue="" onChange={ this.handleTimelineEventTypeChange } data-toggle="popover" data-title="Type Missing!" data-content="Please select an appropriate timeline event type." data-placement="bottom">

              <option disabled="disabled" value="">Select Type</option>
              { Object.keys(this.props.timelineEventTypes).map(function (role, index) {
                return <TimelineBuilderTimelineEventGroup key={ index } role={ role } timelineEvents={ this.props.timelineEventTypes[role] }/>
              }, this)}
            </select>
          </div>
          <TimelineBuilderSubmitButton submissionProgress={ this.props.submissionProgress } submitCB={ this.props.submitCB }/>
        </div>
      </div>
    )
  }
});
