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
    console.log(this.props.target.link_to_complete);
    console.log(this.props.target.submittability);
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
  AutoVerificationCheck() {
    if (this.props.target.submittability == "auto_verify") {
      return (
        "/targets/" +
        this.props.target.id +
        "/" +
        this.props.target.submittability
      );
    } else return this.props.target.link_to_complete;
  }

  successCallback() {
    debugger;
  }

  errorCallback() {
    debugger;
  }

  test() {
    let target = this.props.target.id;
    let sub = this.props.target.submittability;
    let url_test = "/targets/" + target + "/" + sub;

    console.log(url_test);

    fetch(url_test, {
      method: "POST",
      credentials: "include",
      body: JSON.stringify(this.props.rootProps.authenticityToken),
      headers: {
        "content-type": "application/json"
      }
    }).then(response => {
      debugger;
    });
    debugger;
  }

  render() {
    return (
      <div className="pull-right">
        {!this.props.target.link_to_complete && (
          <a
            href={this.AutoVerificationCheck()}
            className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder js-founder-dashboard__action-bar-add-event-button"
          >
            <i className={this.submitButtonIconClass()} aria-hidden="true" />
            <span>{this.submitButtonText()}</span>
          </a>
        )}
        {this.props.target.link_to_complete && (
          <button
            onClick={this.test}
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
