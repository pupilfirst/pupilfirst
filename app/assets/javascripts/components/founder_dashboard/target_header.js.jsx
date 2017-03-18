class FounderDashboardTargetHeader extends React.Component {
  statusBadgeClasses() {
    let classes = "founder-dashboard-target-header__status-badge tag tag-pill";
    let statusClass = this.props.target.status.replace('_', '-');
    classes += (' ' + statusClass);
    return classes;
  }

  containerClasses() {
    let classes = 'founder-dashboard-target-header__container clearfix';

    if (this.props.descriptionOpen) {
      classes += '  founder-dashboard-target-header__container--active';
    }

    return classes;
  }

  targetType() {
    return <span className="founder-dashboard-target-header__type-tag hidden-sm-down">
      { this.props.target.role === 'founder' ? 'Founder' : 'Team' }:
      </span>;
  }

  pointsEarnable() {
    if (typeof(this.props.target.points_earnable) === 'undefined' || this.props.target.points_earnable === null) {
      return null;
    } else {
      return (
        <div
          className="founder-dashboard-target-header__info-subtext founder-dashboard-target-header__karma-points font-regular hidden-sm-down">
          Karma Points:
          <span className="founder-dashboard-target-header__info-value">
          { this.props.target.points_earnable }
        </span>
        </div>
      );
    }
  }

  targetDateString() {
    if (this.props.displayDate) {
      return this.sessionAtString();
    } else {
      return this.daysToCompleteString();
    }
  }

  sessionAtString() {
    if (typeof(this.props.target.session_at) === 'undefined' || this.props.target.session_at === null) {
      return null;
    } else {
      return (
        <span>
          Session at:
          <span className="founder-dashboard-target-header__info-value">
            { moment(this.props.target.session_at).format('MMM D, h:mm A') }
          </span>
        </span>
      );
    }
  }

  daysToCompleteString() {
    if (typeof(this.props.target.days_to_complete) === 'undefined' || this.props.target.days_to_complete === null) {
      return null;
    } else {
      return (
        <span>
          Time required:
          <span className="founder-dashboard-target-header__info-value">
            { this.props.target.days_to_complete } days
          </span>
        </span>
      );
    }
  }

  statusString() {
    switch (this.props.target.status) {
      case 'complete':
        return 'Complete';
      case 'needs_improvement':
        return 'Needs Improvement';
      case 'submitted':
        return 'Submitted';
      case 'expired':
        return 'Expired';
      case 'pending':
        return 'Pending';
      case 'unavailable':
        return 'Locked';
      case 'not_accepted':
        return 'Not Accepted';
    }
  }

  render() {
    return (
      <div className={ this.containerClasses() } onClick={ this.props.onClickCB }>
        <img className="founder-dashboard-target-header__icon"
          src={'/assets/founders/dashboard/target-type-icons/personal_todo_icon.svg'}/>

        <div className="founder-dashboard-target-header__title">
          <h6 className="founder-dashboard-target-header__headline">
            { this.targetType() }
            { this.props.target.title }
          </h6>

          <div className="founder-dashboard-target-header__headline-info">
            <div className="founder-dashboard-target-header__info-subtext font-regular">
              { this.targetDateString() }
              { this.pointsEarnable() }
            </div>
          </div>
        </div>

        <div className={ this.statusBadgeClasses() }>
          <span className="founder-dashboard-target-header__status-badge-icon">
            <i className="fa"/>
          </span>

          <span className="hidden-sm-down">
            { this.statusString() }
          </span>
        </div>
      </div>
    );
  }
}

FounderDashboardTargetHeader.propTypes = {
  onClickCB: React.PropTypes.func,
  descriptionOpen: React.PropTypes.bool,
  target: React.PropTypes.object,
  displayDate: React.PropTypes.bool
};

FounderDashboardTargetHeader.defaultProps = {
  displayDate: false
};
