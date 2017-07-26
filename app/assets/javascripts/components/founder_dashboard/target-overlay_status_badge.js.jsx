class TargetOverlayStatusBadge extends React.Component {
  containerClasses() {
    let classes = "target-overlay-header__status-badge__container tag tag-pill";
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
    switch (this.props.target.status) {
      case 'complete':
        return 'Completed';
      case 'needs_improvement':
        return 'Needs Improvement';
      case 'submitted':
        return 'Submitted';
      case 'pending':
        return 'Pending';
      case 'unavailable':
        return 'Locked';
      case 'not_accepted':
        return 'Not Accepted';
    }
  }

  statusContents() {
    let grade = ['good', 'great', 'wow'].indexOf(this.props.target.grade) + 1;

    if (grade === 0) {
      return <span>
        <span className="target-overlay-header__status-badge-icon">
          <i className={ this.statusIconClasses() }/>
        </span>

        <span className="hidden-sm-down">
          { this.statusString() }
        </span>
      </span>;
    } else {
      let filledStars = _.times(grade).map(function (e, i) {
        return <i key={ "filled-star-" + this.props.target.id + "-" + i }
          className='fa fa-star target-overlay-header__status-badge-star'/>;
      }, this);

      let emptyStars = _.times(3 - grade).map(function (e, i) {
        return <i key={ "empty-star-" + this.props.target.id + "-" + i }
          className='fa fa-star-o target-overlay-header__status-badge-star'/>;
      }, this);

      let gradeString = this.props.target.grade.charAt(0).toUpperCase() + this.props.target.grade.slice(1);

      return <span>
        { filledStars }
        { emptyStars }

        <span className="hidden-sm-down">
          &nbsp;{ gradeString }!
        </span>
      </span>;
    }
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        { this.statusContents() }
      </div>
    );
  }
}

TargetOverlayStatusBadge.propTypes = {
  target: React.PropTypes.object
};