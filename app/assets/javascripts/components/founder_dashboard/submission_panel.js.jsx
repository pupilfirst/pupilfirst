class FounderDashboardSubmissionPanel extends React.Component {
  constructor(props) {
    super(props);

    this.handleSubmitClick = this.handleSubmitClick.bind(this);
  }

  isSubmittable() {
    return !(this.isNotSubmittable() || this.singleSubmissionComplete() || this.submissionBlocked());
  }

  isNotSubmittable() {
    return this.props.target.submittability === 'not_submittable';
  }

  singleSubmissionComplete() {
    return this.props.target.submittability === 'submittable_once' && !this.isPending();
  }

  submissionBlocked() {
    return ['unavailable', 'submitted'].indexOf(this.props.target.status) != -1;
  }

  isPending() {
    return (this.props.target.status === 'pending');
  }

  targetFeedbackClasses() {
    let classes = 'target-feedback';
    let statusClass = this.props.target.status.replace('_', '-');
    classes += (' ' + statusClass);
    return classes;
  }

  statusIconClasses() {
    let classes = 'fa';

    switch (this.props.target.status) {
      case 'complete':
        classes += ' fa-thumbs-o-up';
        break;
      case 'needs_improvement':
        classes += ' fa-line-chart';
        break;
      case 'not_accepted':
        classes += ' fa-thumbs-o-down';
        break;
      case 'unavailable':
        classes += ' fa-lock';
        break;
      case 'submitted':
        classes += ' fa-hourglass-half';
        break;
      case 'pending':
        classes += ' fa-clock-o';
    }

    return classes;
  }

  statusReportText() {
    switch (this.props.target.status) {
      case 'complete':
        return 'Target Completed';
      case 'needs_improvement':
        return 'Submission Needs Improvement';
      case 'submitted':
        return 'Submission Being Verified';
      case 'pending':
        return 'Target Pending';
      case 'unavailable':
        return 'Target Locked';
      case 'not_accepted':
        return 'Submission Not Accepted';
    }
  }

  statusHintText() {
    switch (this.props.target.status) {
      case 'complete':
        return 'Completed on ' + this.submittedAt();
      case 'needs_improvement':
        return 'Consider feedback and try re-submitting!';
      case 'submitted':
        return 'Submitted on ' + this.submittedAt();
      case 'pending':
        return 'Follow completion instructions and submit!';
      case 'unavailable':
        return 'Complete prerequisites first!';
      case 'not_accepted':
        return 'Re-submit based on feedback!';
    }
  }

  submittedAt() {
    if (this.props.target.status == 'submitted' || this.props.target.status == 'complete') {
      return moment(this.props.target.submitted_at).format('MMM D')
    } else {
      console.error('submittedAt() called for target with status ' + this.props.target.status);
      return null;
    }
  }

  submitButtonText() {
    let hasLinkToComplete = this.props.target.link_to_complete
    if (hasLinkToComplete !== null) {
      return this.isPending() ? 'Complete' : 'Update';
    } else {
      return this.isPending() ? 'Submit' : 'Re-Submit';
    }
  }

  handleSubmitClick() {
    this.props.openTimelineBuilderCB(this.props.target.id, this.props.target.timeline_event_type_id);
  }

  render() {
    return (
      <div className="complete-target-block m-t-1 text-xs-center">
        { !this.isPending() &&
        <div className={ this.targetFeedbackClasses() }>
          <div className="feedback-icon img-circle">
            <i className={ this.statusIconClasses() }/>
          </div>
          <div className="feedback-message text-xs-left">
            <p className="feedback-message-head font-semibold">
              { this.statusReportText() }
            </p>
            <p className="feedback-message-detail">
              { this.statusHintText() }
            </p>
          </div>
        </div>
        }

        { this.isSubmittable() &&
        <div>
          <div className="submit-instruction font-regular">
            <p>{ this.props.target.completion_instructions }</p>
          </div>
          { this.props.target.link_to_complete &&
          <a href={this.props.target.link_to_complete}
                  className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder">
            <i className="fa fa-upload"/>
            { this.submitButtonText() }
          </a>
          }
          { !this.props.target.link_to_complete &&
          <button onClick={ this.handleSubmitClick }
                  className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder">
            <i className="fa fa-upload"/>
            { this.submitButtonText() }
          </button>
          }
        </div>
        }
      </div>
    );
  }
}

FounderDashboardSubmissionPanel.propTypes = {
  target: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func
};
