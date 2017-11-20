class TargetOverlayStatusBadgeBar extends React.Component {
  containerClasses() {
    let classes = "target-overlay-status-badge-bar__badge-container tag tag-pill";
    let statusClass = this.props.target.status.replace('_', '-');
    classes += (' ' + statusClass);
    return classes;
  }

  statusIconClasses() {
    return {
      complete: 'fa fa-thumbs-o-up',
      needs_improvement: 'fa fa-line-chart',
      submitted: 'fa fa-hourglass-half',
      pending: 'fa fa-clock-o',
      unavailable: 'fa fa-lock',
      not_accepted: 'fa fa-thumbs-o-down'
    }[this.props.target.status];
  }

  statusString() {
    return {
      complete: 'Completed',
      needs_improvement: 'Needs Improvement',
      submitted: 'Submitted',
      pending: 'Pending',
      unavailable: 'Locked',
      not_accepted: 'Not Accepted'
    }[this.props.target.status];
  }

  statusHintString() {
    return {
      complete: 'Completed on ' + this.submissionDate(),
      needs_improvement: 'Consider feedback and try re-submitting!',
      submitted: 'Submitted on ' + this.submissionDate(),
      pending: 'Follow completion instructions and submit!',
      unavailable: 'Complete prerequisites first!',
      not_accepted: 'Re-submit based on feedback!'
    }[this.props.target.status];
  }

  submissionDate() {
    return moment(this.props.target.submitted_at).format('MMM D');
  }

  statusContents() {
    let grade = ['good', 'great', 'wow'].indexOf(this.props.target.grade) + 1;

    if (this.props.target.status != 'complete' || grade === 0) {
      return <div className="target-overlay-status-badge-bar__badge-content">
        <span className="target-overlay-status-badge-bar__badge-icon">
          <i className={ this.statusIconClasses() }/>
        </span>

        <span>
          { this.statusString() }
        </span>
      </div>;
    } else {
      let filledStars = _.times(grade).map(function (e, i) {
        return <i key={ "filled-star-" + this.props.target.id + "-" + i }
          className='fa fa-star founder-dashboard-target-header__status-badge-star'/>;
      }, this);

      let emptyStars = _.times(3 - grade).map(function (e, i) {
        return <i key={ "empty-star-" + this.props.target.id + "-" + i }
          className='fa fa-star-o founder-dashboard-target-header__status-badge-star'/>;
      }, this);

      let gradeString = this.props.target.grade.charAt(0).toUpperCase() + this.props.target.grade.slice(1);

      return <div className="target-overlay-status-badge-bar__badge-content">
        { filledStars }
        { emptyStars }

        <span>
          &nbsp;{ gradeString }!
        </span>
      </div>;
    }
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        { this.statusContents() }
        <div className="target-overlay-status-badge-bar__info-block">
          <p className="target-overlay-status-badge-bar__hint font-regular">{ this.statusHintString() }</p>
        </div>
      </div>
    );
  }
}

TargetOverlayStatusBadgeBar.propTypes = {
  target: React.PropTypes.object
};
