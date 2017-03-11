class FounderDashboardSubmissionPanel extends React.Component {

  render() {
    return (
      <div className="complete-target-block m-t-1 text-xs-center">
      {/*- unless target.pending_for?(current_founder)*/}
        <div className="target-feedback">{/*className="#{target.status_badge_class(current_founder)}"*/}
          <div className="feedback-icon img-circle">
            <i className="fa fa-hourglass-end"/>{/*className="#{target.status_fa_icon(current_founder)}"*/}
          </div>
          <div className="feedback-message text-xs-left">
            <p className="feedback-message-head font-semibold">
              {/*| #{target.status_report_text(current_founder)}*/}
              Target Expired
            </p>
            <p className="feedback-message-detail">
              {/*| #{target.status_hint_text(current_founder)}*/}
              You can still try submitting!
            </p>
          </div>
        </div>

      {/*- if target.submittable?(current_founder)*/}
        <div className="submit-instruction font-regular">
          <p>
            {/*' #{target.completion_instructions}
          / TODO: Probably show feedback too here, if available*/}
            Discuss amongst your team, get updates from everybody, and then post
            a Attended SV.CO Session event talking about the top 3 nuggets you
            picked up from this session/book.
          </p>
        </div>
        <button className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder" data-toggle="modal">
          <i className="fa fa-upload"/>
          {/*' #{target.submit_button_text(current_founder)}*/}
          Submit
        </button>
      </div>
    );
  }
}
