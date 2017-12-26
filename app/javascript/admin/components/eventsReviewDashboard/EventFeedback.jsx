import React from "react";
import PropTypes from "prop-types";
import FeedbackActions from "./FeedbackActions";
import TrixEditor from "./TrixEditor";

export default class EventFeedback extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      feedback: "",
      showFeedbackForm: false,
      feedbackMissing: false,
      feedbackId: null,
      founderId: null
    };

    this.eventFeedbackFormId = this.eventFeedbackFormId.bind(this);
    this.feedbackChange = this.feedbackChange.bind(this);
    this.saveFeedback = this.saveFeedback.bind(this);
    this.toggleFeedbackForm = this.toggleFeedbackForm.bind(this);
    this.markFeedbackRecorded = this.markFeedbackRecorded.bind(this);
  }

  eventFeedbackFormId() {
    return "event-feedback-form-" + this.props.eventId;
  }

  feedbackChange(value) {
    this.setState({ feedback: value, feedbackMissing: false });
  }

  markFeedbackRecorded(feedbackId, founderId) {
    this.setState({ feedbackId: feedbackId, founderId: founderId });
  }

  saveFeedback(event) {
    this.setState({ feedbackMissing: false });
    if (!this.state.feedback) {
      this.setState({ feedbackMissing: true });
    } else {
      let eventId = this.props.eventId;
      let feedback = this.state.feedback;
      let toggleFeedbackForm = this.toggleFeedbackForm;
      let markFeedbackRecorded = this.markFeedbackRecorded;
      let postUrl = "/admin/timeline_events/" + eventId + "/save_feedback";

      $.post({
        url: postUrl,
        data: { feedback: feedback },
        beforeSend: function() {
          event.target.innerHTML = "Saving Feedback...";
        }
      })
        .done(function(response) {
          new PNotify({
            title: "Feedback Saved!",
            text:
              "Your feedback for event " + eventId + " was saved successfully"
          });

          markFeedbackRecorded(response.feedback_id, response.founder_id);
          toggleFeedbackForm();
        })
        .fail(function() {
          alert("Failed to save your feedback. Try again.");
        });
    }
  }

  toggleFeedbackForm() {
    this.setState({ showFeedbackForm: !this.state.showFeedbackForm });
  }

  render() {
    return (
      <div className="margin-bottom-10">
        {!this.state.showFeedbackForm && (
          <div>
            {this.state.feedbackId != null && (
              <FeedbackActions
                feedbackId={this.state.feedbackId}
                founderId={this.state.founderId}
                levelZero={this.props.levelZero}
                eventId={this.props.eventId}
              />
            )}
            {this.state.feedbackId == null && (
              <div>
                <i className="fa fa-comment-o" />&nbsp;
                <a className="cursor-pointer" onClick={this.toggleFeedbackForm}>
                  Add Feedback
                </a>
              </div>
            )}
          </div>
        )}

        {this.state.showFeedbackForm && (
          <div>
            <TrixEditor
              onChange={this.feedbackChange}
              value={this.state.feedback}
            />
            <br />
            <a className="button cursor-pointer" onClick={this.saveFeedback}>
              Save Feedback
            </a>
            <a
              className="button cursor-pointer"
              onClick={this.toggleFeedbackForm}
            >
              Close
            </a>
            {this.state.feedbackMissing && (
              <div style={{ color: "red" }}>Enter a feedback first!</div>
            )}
          </div>
        )}
      </div>
    );
  }
}

EventFeedback.propTypes = {
  eventId: PropTypes.number,
  levelZero: PropTypes.bool
};
