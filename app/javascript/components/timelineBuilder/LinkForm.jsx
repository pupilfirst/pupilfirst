import React from "react";
import PropTypes from "prop-types";

export default class LinkForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      hasTitleError: false,
      hasUrlError: false
    };

    this.linkSubmit = this.linkSubmit.bind(this);
    this.clearUrlError = this.clearUrlError.bind(this);
    this.clearTitleError = this.clearTitleError.bind(this);
  }

  linkSubmit(event) {
    event.preventDefault();

    if (this.validate()) {
      this.storeLink();
      setTimeout(this.clearForm, 500);
    }
  }

  clearForm() {
    $(".js-link-title").val("");
    $(".js-link-url").val("");
    $(".js-link-visibility").val("public");
  }

  validate() {
    let titleError = false;
    let urlError = false;

    if ($(".js-link-title").val().length === 0) {
      titleError = true;
    }

    if (this.isInvalidUrl($(".js-link-url").val())) {
      urlError = true;
    }

    if (titleError || urlError) {
      this.setState({ hasTitleError: titleError, hasUrlError: urlError });
      return false;
    }

    return true;
  }

  isInvalidUrl(url) {
    return !(
      url.length > 0 &&
      /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(
        url
      )
    );
  }

  storeLink() {
    this.props.addAttachmentCB("link", {
      title: $(".js-link-title").val(),
      url: $(".js-link-url").val(),
      private: $(".js-link-visibility").val() == "private"
    });
  }

  titleFormGroupClasses() {
    return (
      "form-group timeline-builder__form-group" +
      (this.state.hasTitleError ? " has-danger" : "")
    );
  }

  urlFormGroupClasses() {
    return (
      "form-group timeline-builder__form-group" +
      (this.state.hasUrlError ? " has-danger" : "")
    );
  }

  clearTitleError() {
    this.setState({ hasTitleError: false });
  }

  clearUrlError() {
    this.setState({ hasUrlError: false });
  }

  titleInputClasses() {
    const classes = "form-control link-title js-link-title";

    if (this.state.hasTitleError) {
      return classes + " is-invalid";
    }

    return classes;
  }

  urlInputClasses() {
    const classes = "form-control link-url js-link-url";

    if (this.state.hasUrlError) {
      return classes + " is-invalid";
    }

    return classes;
  }

  render() {
    return (
      <form className="timeline-builder__attachment-form" noValidate={true}>
        <div className={this.titleFormGroupClasses()}>
          <label
            className="sr-only"
            htmlFor="timeline-builder__link-title-input"
          >
            Link Title
          </label>

          <input
            id="timeline-builder__link-title-input"
            className={this.titleInputClasses()}
            type="text"
            placeholder="Title"
            onFocus={this.clearTitleError}
          />

          <div className="invalid-feedback">Enter a valid title!</div>
        </div>
        <div className={this.urlFormGroupClasses()}>
          <label className="sr-only" htmlFor="timeline-builder__link-url-input">
            URL
          </label>

          <input
            id="timeline-builder__link-url-input"
            className={this.urlInputClasses()}
            type="text"
            placeholder="URL"
            onFocus={this.clearUrlError}
          />

          <div className="invalid-feedback">Enter a valid URL!</div>
          <small className="form-text text-muted">
            Please enter a full URL, starting with http(s).
          </small>
        </div>
        <div className="form-group timeline-builder__form-group timeline-builder__visibility-option-group">
          <label
            className="sr-only"
            htmlFor="timeline-builder__link-visibility-select"
          >
            Link Visibility
          </label>
          <select
            id="timeline-builder__link-visibility-select"
            className="form-control timeline-builder__visibility-option js-link-visibility"
          >
            <option value="public">Public</option>
            <option value="private">Private</option>
          </select>
        </div>
        <button
          onClick={this.linkSubmit}
          className="btn btn-secondary text-uppercase timeline-builder__attachment-button js-timeline-builder__add-link-button"
        >
          Add Link
        </button>
      </form>
    );
  }
}

LinkForm.propTypes = {
  addAttachmentCB: PropTypes.func
};
