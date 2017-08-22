class TargetOverlayStatusBadgeBar extends React.Component {
  containerClasses() {
    let classes = "target-overlay__status-badge-container tag tag-pill";
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

  statusContents() {
    let grade = ['good', 'great', 'wow'].indexOf(this.props.target.grade) + 1;

    if (this.props.target.status != 'complete' || grade === 0) {
      return <div className="target-overlay__status-badge-content">
        <span className="target-overlay__status-badge-icon">
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

      return <div className="target-overlay__status-badge-content">
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
        <div className="target-overlay__status-info-block">
          <p className="target-overlay__status-hint font-regular">Consider feedback and try re-submitting!</p>
        </div>
      </div>
    );
  }
}

TargetOverlayStatusBadgeBar.propTypes = {
  target: React.PropTypes.object
};