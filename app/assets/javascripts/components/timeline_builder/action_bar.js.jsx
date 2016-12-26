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
    hasSubmissionError: React.PropTypes.bool,
    attachmentAllowed: React.PropTypes.bool,
    showDateError: React.PropTypes.bool,
    showEventTypeError: React.PropTypes.bool,
    resetErrorsCB: React.PropTypes.func,
    timelineEventTypeId: React.PropTypes.string
  },

  componentDidUpdate: function () {
    if (this.props.showDateError) {
      $('.date-of-event').popover('show');
    } else {
      $('.date-of-event').popover('hide');
    }
  },

  formLinkClasses: function (type) {
    let classes = '';

    if (type == 'link') {
      classes = 'timeline-builder__upload-section-tab link-upload' + (this.props.attachmentAllowed ? '' : ' action-tab-disabled')
    } else if (type == 'file') {
      classes = 'timeline-builder__upload-section-tab file-upload' + (this.props.attachmentAllowed ? '' : ' action-tab-disabled')
    } else {
      classes = 'timeline-builder__upload-section-tab date-of-event'
    }

    if (this.props.currentForm == type) {
      classes += ' timeline-builder__active-tab';
    }

    return classes;
  },

  showLinkForm: function () {
    if (this.props.attachmentAllowed) {
      this.props.formClickedCB('link');
    }
  },

  showFileForm: function () {
    if (this.props.attachmentAllowed) {
      this.props.formClickedCB('file');
    }
  },

  showDateForm: function () {
    this.props.resetErrorsCB();
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

  render: function () {
    return (
      <div className="timeline-builder__submit-tabs">
        <div className="timeline-builder__upload-section">
          <TimelineBuilderImageButton key={ this.props.imageButtonKey } coverImage={ this.props.coverImage }
                                      addDataCB={ this.props.addDataCB }/>
          <div className={ this.formLinkClasses('link') } onClick={ this.showLinkForm }>
            <i className="timeline-builder__upload-section-icon fa fa-link"/>
            <span className="timeline-builder__tab-label">Link</span>
          </div>
          <div className={ this.formLinkClasses('file') } onClick={ this.showFileForm }>
            <i className="timeline-builder__upload-section-icon fa fa-file-text-o"/>
            <span className="timeline-builder__tab-label">File</span>
          </div>
          <div className={ this.formLinkClasses('date') } onClick={ this.showDateForm } data-toggle="popover"
               data-title="Date Missing!" data-content="Please select a date for the event." data-placement="bottom"
               data-trigger="manual">
            <i className="timeline-builder__upload-section-icon fa fa-calendar"/>
            <span className="timeline-builder__tab-label">{ this.dateLabel() }</span>
          </div>
        </div>

        <div className="timeline-builder__select-section">
          <TimelineBuilderEventTypeSelect resetErrorsCB={ this.props.resetErrorsCB }
                                          addDataCB={ this.props.addDataCB }
                                          timelineEventTypes={ this.props.timelineEventTypes }
                                          timelineEventTypeId={ this.props.timelineEventTypeId }
                                          showEventTypeError={ this.props.showEventTypeError }/>
          <TimelineBuilderSubmitButton submissionProgress={ this.props.submissionProgress }
                                       submitCB={ this.props.submitCB }
                                       hasSubmissionError={ this.props.hasSubmissionError }/>
        </div>
      </div>
    )
  }
});
