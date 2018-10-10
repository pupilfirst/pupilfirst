import React from "react";
import PropTypes from "prop-types";

export default class SubmitButton extends React.Component {
  constructor(props) {
    super(props);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
    this.autoVerify = this.autoVerify.bind(this);
    this.handleClick = this.handleClick.bind(this);
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
    } else if (this.canBeVerifiedAutomatically()) {
      return "Mark COMPLETE";
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

  autoVerify() {
    const autoVerifyEndpoint =
      "/targets/" + this.props.target.id + "/auto_verify";

    fetch(autoVerifyEndpoint, {
      method: "POST",
      credentials: "include",
      body: JSON.stringify({
        authenticity_token: this.props.rootProps.authenticityToken
      }),
      headers: {
        "content-type": "application/json"
      }
    }).then(() => {
      new PNotify({
        title: "Done!",
        text: "This target has been marked as complete.",
        type: "success"
      });
      this.props.completeTargetCB();
    });
  }

  handleClick() {
    if (this.canBeVerifiedAutomatically()) {
      this.autoVerify();
    } else {
      this.openTimelineBuilder();
    }
  }

  hasLinkToComplete() {
    const linkToComplete = this.props.target.link_to_complete;
    return _.isString(linkToComplete) && linkToComplete.length > 0;
  }

  canBeVerifiedAutomatically() {
    return this.props.target.submittability === "auto_verify";
  }

  submitButtonContents() {
    return [
      <i className={this.submitButtonIconClass()} aria-hidden="true" />,
      <span>{this.submitButtonText()}</span>
    ];
  }

  submitButtonClasses() {
    return "btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder js-founder-dashboard__action-bar-add-event-button";
  }

  render() {
    return (
      <div className="pull-right">
        {this.hasLinkToComplete() &&
          !this.canBeVerifiedAutomatically() && (
            <a
              href={this.props.target.link_to_complete}
              className={this.submitButtonClasses()}
            >
              {this.submitButtonContents()}
            </a>
          )}
        {(!this.hasLinkToComplete() || this.canBeVerifiedAutomatically()) && (
          <button
            onClick={this.handleClick}
            className={this.submitButtonClasses()}
          >
            {this.submitButtonContents()}
          </button>
        )}
      </div>
    );
  }
}

SubmitButton.propTypes = {
  rootProps: PropTypes.object.isRequired,
  completeTargetCB: PropTypes.func.isRequired,
  target: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func
};
