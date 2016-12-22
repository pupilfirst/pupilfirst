const TimelineBuilderLinkForm = React.createClass({
  propTypes: {
    addAttachmentCB: React.PropTypes.func
  },

  getInitialState: function () {
    return {
      hasTitleError: false,
      hasUrlError: false
    }
  },

  linkSubmit: function (event) {
    event.preventDefault();

    if (this.validate()) {
      this.storeLink();
      setTimeout(this.clearForm, 500);
    }
  },

  clearForm: function () {
    $('.js-link-title').val('');
    $('.js-link-url').val('');
    $('.js-link-visibility').val('public');
  },

  validate: function () {
    let titleError = false;
    let urlError = false;

    if ($('.js-link-title').val().length == 0) {
      titleError = true;
    }

    if (this.isInvalidUrl($('.js-link-url').val())) {
      urlError = true;
    }

    if (titleError || urlError){
      this.setState({hasTitleError: titleError, hasUrlError: urlError});
      return false;
    }

    return true;
  },

  isInvalidUrl: function (url) {
    return !(url.length > 0 && /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url));
  },

  storeLink: function () {
    this.props.addAttachmentCB('link', {
      title: $('.js-link-title').val(),
      url: $('.js-link-url').val(),
      visibility: $('.js-link-visibility').val()
    });
  },

  titleFormGroupClasses: function() {
    return "form-group link-title-group" + (this.state.hasTitleError ? ' has-danger' : '');
  },

  urlFormGroupClasses: function() {
    return "form-group link-url-group" + (this.state.hasUrlError ? ' has-danger' : '');
  },

  clearTitleError: function () {
    this.setState({hasTitleError: false});
  },

  clearUrlError: function () {
    this.setState({hasUrlError: false});
  },

  render: function () {
    return (
      <form className="form-inline attachment-form">
        <div className={ this.titleFormGroupClasses() }>
          <label className="sr-only" htmlFor="linkTitle">Link Title</label>
          <input className="form-control link-title js-link-title" type="text" placeholder="Title" onFocus={ this.clearTitleError }/>
          { this.state.hasTitleError &&
          <div className="form-control-feedback">Enter a valid title!</div>
          }
        </div>
        <div className={ this.urlFormGroupClasses() }>
          <label className="sr-only" htmlFor="linkUrl">URL</label>
          <input className="form-control link-url js-link-url" type="text" placeholder="URL" onFocus={ this.clearUrlError }/>
          { this.state.hasUrlError &&
          <div className="form-control-feedback">Enter a valid URL!</div>
          }
          <small className="form-text text-muted">Please enter a full URL, starting with http(s).</small>
        </div>
        <div className="form-group visibility-option-group">
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
