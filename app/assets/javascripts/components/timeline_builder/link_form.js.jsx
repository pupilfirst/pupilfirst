const TimelineBuilderLinkForm = React.createClass({
  propTypes: {
    addAttachmentCB: React.PropTypes.func
  },

  linkSubmit: function (event) {
    event.preventDefault();

    // TODO: Add validations.

    this.props.addAttachmentCB('link', {
      title: $('.js-link-title').val(),
      url: $('.js-link-url').val(),
      visibility: $('.js-link-visibility').val()
    });

    setTimeout(this.clearForm, 500);
  },

  clearForm: function() {
    $('.js-link-title').val('');
    $('.js-link-url').val('');
    $('.js-link-visibility').val('public');
  },

  render: function () {
    return (
      <form className="form-inline timeline-builder__attachment-form">
        <div className="form-group timeline-builder__form-group">
          <label className="sr-only" htmlFor="linkTitle">Link Title</label>
          <input className="form-control link-title js-link-title" type="text" placeholder="Title"/>
        </div>
        <div className="form-group timeline-builder__form-group">
          <label className="sr-only" htmlFor="linkUrl">URL</label>
          <input className="form-control link-url js-link-url" type="text" placeholder="URL"/>
          <small className="form-text text-muted hidden-xs-up">Please enter a full URL, starting with http(s).</small>
        </div>
        <div className="form-group timeline-builder__form-group timeline-builder__visibility-option-group">
          <select className="form-control visibility-option js-link-visibility">
            <option value="public">Public</option>
            <option value="private">Private</option>
          </select>
        </div>
        <button className="btn btn-secondary" onClick={ this.linkSubmit }>
          <i className="fa fa-check"/>
        </button>
      </form>
    )
  }
});
