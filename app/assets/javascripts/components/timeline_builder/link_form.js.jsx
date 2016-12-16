const TimelineBuilderLinkForm = React.createClass({
  getInitialState: function () {
    return null;
  },

  render: function () {
    return (
      <form className="form-inline attachment-form">
        <div className="form-group link-title-group">
          <label className="sr-only" htmlFor="linkTitle">Link Title</label>
          <input className="form-control link-title" type="text" placeholder="Title" id="linkTitle"/>
        </div>
        <div className="form-group link-url-group">
          <label className="sr-only" htmlFor="linkUrl">URL</label>
          <input className="form-control link-url" type="text" placeholder="URL" id="linkUrl"/>
          <small className="form-text text-muted hidden-xs-up">Please enter a full URL, starting with http(s).</small>
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
