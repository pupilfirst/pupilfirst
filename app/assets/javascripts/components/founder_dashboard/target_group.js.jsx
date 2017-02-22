class FounderDashboardTargetGroup extends React.Component {

  render() {
    return (
      <div className="founder-dashboard-target-group__container p-x-1 m-x-auto">
        <div className="founder-dashboard-target-group__box">
          <div className="founder-dashboard-target-group__header text-xs-center">
            <h4 className="brand-primary font-regular">
              {/*#{target_group.name}*/}
              Weekly Updates
            </h4>
            <div className="founder-dashboard-target-group__header-info">
              {/*#{target_group.description}*/}
              Get in sync with the Program
            </div>
          </div>
          <FounderDashboardTarget/>
        </div>
      </div>
    );
  }
}