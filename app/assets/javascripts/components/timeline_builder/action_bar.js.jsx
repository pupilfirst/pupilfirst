const TimelineBuilderActionBar = React.createClass({
  propTypes: {
    formClickedCB: React.PropTypes.func,
    currentForm: React.PropTypes.string,
    submitCB: React.PropTypes.func
  },

  getInitialState: function () {
    return null;
  },

  formLinkClasses: function (type) {
    let classes = (type == 'link') ? 'link-upload' : 'file-upload';

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

  render: function () {
    return (
      <div className="timeline-submit-tabs">
        <div className="upload-tabs">
          <div className="image-upload">
            <i className="fa fa-file-image-o"/>
            <span className="tab-label">Image</span>
          </div>
          <div className={ this.formLinkClasses('link') } onClick={ this.showLinkForm }>
            <i className="fa fa-link"/>
            <span className="tab-label">Link</span>
          </div>
          <div className={ this.formLinkClasses('file') } onClick={ this.showFileForm }>
            <i className="fa fa-file-text-o"/>
            <span className="tab-label">File</span>
          </div>
          <div className="date-of-event">
            <i className="fa fa-calendar"/>
            <span className="tab-label">Date</span>
          </div>
        </div>
        <div className="select-tabs">
          <div className="type-of-event-select">
            <select className="form-control" id="typeofEvent">
              <option>Type of Event</option>
              <option>Moved to Prototyping Stage Stage Stage</option>
              <option>Joined sv.co</option>
              <option>Received Bank Loan</option>
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
