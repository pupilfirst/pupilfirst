import React from "react";
import PropTypes from "prop-types";

export default class SubmitButton extends React.Component {
  constructor(props) {
    super(props);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
    this.test = this.test.bind(this);
  }

  openTimelineBuilder() {
    this.props.openTimelineBuilderCB(
      this.props.target.id,
      this.props.target.timeline_event_type_id
    );
  }

  submitButtonText() {
    if (this.props.target.call_to_action) {
      return this.props.target.call_to_action;
    } else if (!this.props.target.link_to_complete) {
      return this.isPending() ? "Submit" : "Re-Submit";
    } else {
      return this.isPending() ? "Complete" : "Update";
    }
  }

  submitButtonIconClass() {
    if (this.props.target.call_to_action) {
      return "fa fa-chevron-circle-right";
    } else if (!this.props.target.link_to_complete) {
      return "fa fa-upload";
    } else {
      return "fa fa-external-link-square";
    }
  }

  isPending() {
    return this.props.target.status === "pending";
  }

  successCallback() {
    debugger;
  }

  errorCallback() {
    debugger;
  }

  test() {
    let target = this.props.target.id;
    let url_test = "/targets/" + target + "/auto_verify";

    console.log("POST-ing to URL with fetch: " + url_test);

    fetch(url_test, {
      method: "POST",
      credentials: "include",
      body: JSON.stringify({
        authenticity_token: this.props.rootProps.authenticityToken
      }),
      headers: {
        "content-type": "application/json"
      }
    }).then(() => {
      debugger;
    });
  }

  render() {
    return (
      <div className="pull-right">
        {this.props.target.link_to_complete && (
          <a
            href={this.props.target.link_to_complete}
            className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder js-founder-dashboard__action-bar-add-event-button"
          >
            <i className={this.submitButtonIconClass()} aria-hidden="true" />
            <span>{this.submitButtonText()}</span>
          </a>
        )}
        {this.props.target.submittability === "auto_verify" && (
          <button
            onClick={this.test}
            className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder js-founder-dashboard__action-bar-add-event-button"
          >
            <i className={this.submitButtonIconClass()} aria-hidden="true" />
            <span>{this.submitButtonText()}</span>
          </button>
        )}
        {!this.props.target.link_to_complete &&
          this.props.target.submittability !== "auto_verify" && (
            <button
              onClick={this.openTimelineBuilder}
              className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder js-founder-dashboard__action-bar-add-event-button"
            >
              <i className={this.submitButtonIconClass()} aria-hidden="true" />
              <span>{this.submitButtonText()}</span>
            </button>
          )}
      </div>
    );
  }
}

SubmitButton.propTypes = {
  rootProps: PropTypes.object.isRequired,
  target: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func
};
