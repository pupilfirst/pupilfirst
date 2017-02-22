class FounderDashboardTargetDescription extends React.Component {

  render() {
    return (
      <div className="target-description">
        <div className="target-description-header clearfix m-b-1">
          {/*- if target.assigner.present?*/}
          <h6 className="pull-sm-left assigner-name m-a-0">
            Assigned by&nbsp;
            <span className="font-regular">
              {/*#{target.assigner.name}*/}
              Vishnu Gopal
            </span>
          </h6>
          <h6 className="pull-sm-right target-due-date m-a-0 alert-background">
            Due date:&nbsp;
            <span className="font-regular">
              {/*#{target.due_date.strftime('%b %e')} at 11:59 PM.*/}
            </span>
          </h6>
        </div>
        <h6 className="founder-dashboard-target-header__headline--sm hidden-md-up">
          {/*#{target.title}*/}
        </h6>
        <p>
          {/*#{target.description.html_safe}*/}
          Complete your founder profile here:
        </p>
      </div>
    );
  }
}