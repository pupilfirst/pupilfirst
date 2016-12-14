const TimelineBuilderActionBar = React.createClass({
  propTypes: {
    adderClickedCB: React.PropTypes.func,
    activeAdder: React.PropTypes.string
  },

  getInitialState: function () {
    return null;
  },

  adderClasses: function (type) {
    let classes = (type == 'link') ? 'link-upload' : 'file-upload';

    if (this.props.activeAdder == type) {
      classes += ' active-tab';
    }

    return classes;
  },

  showLinkAdder: function () {
    this.props.adderClickedCB('link')
  },

  showFileAdder: function () {
    this.props.adderClickedCB('file')
  },

  render: function () {
    return (
      <div className="timeline-submit-tabs">
        <div className="upload-tabs">
          <div className="image-upload">
            <i className="fa fa-file-image-o"/>
            <span className="tab-label">Image</span>
          </div>
          <div className={ this.adderClasses('link') } onClick={ this.showLinkAdder }>
            <i className="fa fa-link"/>
            <span className="tab-label">Link</span>
          </div>
          <div className={ this.adderClasses('file') } onClick={ this.showFileAdder }>
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
            <button type="submit" className="btn btn-primary text-xs-uppercase">
              Submit
            </button>
          </div>
        </div>
      </div>
    )
  }
});
