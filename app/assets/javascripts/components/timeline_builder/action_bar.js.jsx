const TimelineBuilderActionBar = React.createClass({
  getInitialState: function () {
    return null;
  },

  render: function () {
    return (
      <div className="timeline-submit-tabs">
        <div className="upload-tabs">
          <div className="image-upload">
            <i className="fa fa-file-image-o"/>
            <span className="tab-label">Image</span>
          </div>
          <div className="link-upload">
            <i className="fa fa-link"/>
            <span className="tab-label">Link</span>
          </div>
          <div className="file-upload active-tab">
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
