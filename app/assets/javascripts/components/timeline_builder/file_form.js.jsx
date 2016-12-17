const TimelineBuilderFileForm = React.createClass({
  propTypes: {
    addAttachmentCB: React.PropTypes.func
  },

  render: function () {
    return (
      <form className="form-inline attachment-form">
        <div className="form-group file-title-group">
          <label className="sr-only" htmlFor="fileTitle">File Title</label>
          <input className="form-control file-title" type="text" placeholder="Title" id="linkTitle"/>
        </div>
        <div className="form-group file-choose-group">
          <input type="file" className="form-control-file file-choose" id="fileChoose" aria-describedby="fileHelp"/>
          <label htmlFor="fileChoose">
            <span/>
            <div className="choose-file-btn">
              <i className="fa fa-upload"/>
              CHOOSE FILE
            </div>
          </label>
        </div>
        <div className="form-group visibility-option-group">
          <select className="form-control visibility-option">
            <option>Public</option>
            <option>Private</option>
          </select>
        </div>
        <button type="submit" className="btn btn-secondary">
          <i className="fa fa-check"/>
        </button>
      </form>
    )
  }
});
