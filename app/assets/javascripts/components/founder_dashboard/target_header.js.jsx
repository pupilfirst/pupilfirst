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
      { this.props.target.target_type_description }:
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

  headerIcon() {
    if (typeof(this.props.target.session_at) === 'undefined' || this.props.target.session_at === null) {
      return this.props.target.role === 'founder' ? this.props.iconPaths.personalTodo : this.props.iconPaths.teamTodo;
    } else {
      return this.props.iconPaths.attendSession;
    }
  }

  statusContents() {
    let grade = ['good', 'great', 'wow'].indexOf(this.props.target.grade) + 1;

    if (grade === 0) {
      return <span>
        <span className="founder-dashboard-target-header__status-badge-icon">
          <i className={ this.statusIconClasses() }/>
        </span>

        <span className="hidden-sm-down">
          { this.statusString() }
        </span>
      </span>;
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
      <div className={ this.containerClasses() } onClick={ this.props.onClickCB }>
        <img className="founder-dashboard-target-header__icon"
          src={ this.headerIcon() }/>

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
          { this.statusContents() }
        </div>
      </div>
    );
  }
}

FounderDashboardTargetHeader.propTypes = {
  onClickCB: React.PropTypes.func,
  descriptionOpen: React.PropTypes.bool,
  target: React.PropTypes.object,
  displayDate: React.PropTypes.bool,
  iconPaths: React.PropTypes.object
};

FounderDashboardTargetHeader.defaultProps = {
  displayDate: false
};
