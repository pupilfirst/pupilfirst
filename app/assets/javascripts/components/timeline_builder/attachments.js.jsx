const TimelineBuilderAttachments = React.createClass({
  getInitialState: function () {
    return null;
  },

  render: function () {
    return (
      <div className="uploaded-files-block clearfix">
        <div className="uploded-file-tag pull-xs-left m-r-1 m-t-1">
          <i className="fa fa-file-image-o"/>
          <span className="file-name">
                    Cover_photograph.jpg
                  </span>
          <button type="button" className="close remove-uploaded-file">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div className="uploded-file-tag pull-xs-left m-r-1 m-t-1">
          <i className="fa fa-link"/>
          <span className="file-name">
                    Link Title
                  </span>
          <button type="button" className="close remove-uploaded-file">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div className="uploded-file-tag pull-xs-left m-r-1 m-t-1">
          <i className="fa fa-file-text-o"/>
          <span className="file-name">
                    File Name
                  </span>
          <button type="button" className="close remove-uploaded-file">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      </div>
    )
  }
});
