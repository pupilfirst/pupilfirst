class FounderDashboardTargetHeader extends React.Component {
  statusBadgeClasses() {
    let classes = "founder-dashboard-target-header__status-badge tag tag-pill";
    /*classes +="#{target.status_badge_class(current_founder)}"*/
    return classes;
  }

  containerClasses() {
    let classes = 'founder-dashboard-target-header__container clearfix';

    if (this.props.descriptionOpen) {
      classes += '  founder-dashboard-target-header__container--active';
    }

    return classes;
  }

  render() {
    return (
      <div className={ this.containerClasses() } onClick={ this.props.onClickCB }>
        <img className="founder-dashboard-target-header__icon"
          src={'/assets/founders/dashboard/target-type-icons/personal_todo_icon.svg'}/>
        <div className="founder-dashboard-target-header__title">
          <h6 className="founder-dashboard-target-header__headline">
            {/*#{target.team_or_personal}/#{target.target_type}*/}
            <span className="founder-dashboard-target-header__type-tag hidden-sm-down">Team/Todo:</span>
            {/*#{target.title}*/}
            Add Info to your Startup Profile
          </h6>
          <div className="founder-dashboard-target-header__headline-info">
            <div className="founder-dashboard-target-header__info-subtext font-regular">
              Complete by:
              <span className="founder-dashboard-target-header__info-value">
                {/* #{target.due_date.strftime('%b %e')}*/}
                Jan 17
              </span>
              {/*- if target.points_earnable.present? */}
              <div
                className="founder-dashboard-target-header__info-subtext founder-dashboard-target-header__karma-points font-regular hidden-sm-down">
                Karma Points:
                <span className="founder-dashboard-target-header__info-value">
                  {/*#{target.points_earnable}*/}
                  20
                </span>
              </div>
            </div>
          </div>
        </div>
        <div className={ this.statusBadgeClasses() }>
          <span className="founder-dashboard-target-header__status-badge-icon">
            <i className="fa"/>
          </span>
          <span className="hidden-sm-down">
            Pending
            {/*#{target.status_text(current_founder)}*/}
          </span>
        </div>
      </div>
    );
  }
}

FounderDashboardTargetHeader.propTypes = {
  onClickCB: React.PropTypes.func,
  descriptionOpen: React.PropTypes.bool
};
