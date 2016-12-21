const TimelineBuilderActionBar = React.createClass({
  propTypes: {
    formClickedCB: React.PropTypes.func,
    currentForm: React.PropTypes.string,
    submitCB: React.PropTypes.func,
    timelineEventTypes: React.PropTypes.object,
    coverImage: React.PropTypes.object,
    addAttachmentCB: React.PropTypes.func,
    imageButtonKey: React.PropTypes.string,
    selectedDate: React.PropTypes.string
  },

  getInitialState: function () {
    return null;
  },

  formLinkClasses: function (type) {
    let classes = '';

    if (type == 'link') {
      classes = 'link-upload'
    } else if (type == 'file') {
      classes = 'file-upload'
    } else {
      classes = 'date-of-event'
    }

    if (this.props.currentForm == type) {
      classes += ' active-tab';
    }

    return classes;
  },

  showLinkForm: function () {
    this.props.formClickedCB('link')
  },

  showFileForm: function () {
    this.props.formClickedCB('file')
  },

  showDateForm: function () {
    this.props.formClickedCB('date')
  },

  timelineEventTypes: function () {
    Object.keys(this.props.timelineEventTypes).forEach(function (role, _index) {

    });
  },

  dateLabel: function() {
    if (this.props.selectedDate != null) {
      let date = moment(this.props.selectedDate, 'YYYY-MM-DD');
      return date.format('MMM D');
    } else {
      return 'Date';
    }
  },

  render: function () {
    return (
      <div className="timeline-submit-tabs">
        <div className="upload-tabs">
          <TimelineBuilderImageButton key={ this.props.imageButtonKey } coverImage={ this.props.coverImage }
                                      addAttachmentCB={ this.props.addAttachmentCB }/>
          <div className={ this.formLinkClasses('link') } onClick={ this.showLinkForm }>
            <i className="fa fa-link"/>
            <span className="tab-label">Link</span>
          </div>
          <div className={ this.formLinkClasses('file') } onClick={ this.showFileForm }>
            <i className="fa fa-file-text-o"/>
            <span className="tab-label">File</span>
          </div>
          <div className={ this.formLinkClasses('date') } onClick={ this.showDateForm }>
            <i className="fa fa-calendar"/>
            <span className="tab-label">{ this.dateLabel() }</span>
          </div>
        </div>
        <div className="select-tabs">
          <div className="type-of-event-select">
            <select className="form-control timeline-builder__timeline_event_type" defaultValue="">
              <option disabled="disabled" value="">Select Type</option>
              { Object.keys(this.props.timelineEventTypes).map(function (role, index) {
                return <TimelineBuilderTimelineEventGroup key={ index } role={ role }
                                                          timelineEvents={ this.props.timelineEventTypes[role] }/>
              }, this)}
            </select>
          </div>
          <div className="submit-btn">
            <button type="submit" className="btn btn-primary text-xs-uppercase" onClick={ this.props.submitCB }>
              Submit
            </button>
          </div>
        </div>
      </div>
    )
  }
});
