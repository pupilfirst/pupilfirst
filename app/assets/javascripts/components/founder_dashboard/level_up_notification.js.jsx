class FounderDashboardLevelupNotification extends React.Component {
  render() {
    return (
      <div className="founder-dashboard-levelup-notification__container p-x-1 m-x-auto">
        <div className="founder-dashboard-levelup-notification__box text-xs-center p-a-3">
          <h1>
            { '\uD83C\uDF89' }
          </h1>
          <h3 className="brand-primary font-regular">Curabitur lobortis id lorem id</h3>
          <p className="founder-dashboard-levelup__description m-x-auto">Here, I focus on a range of items and features that we use in life without
            giving them a second thought such as Coca Cola, body muscles and holding ones own breath.</p>
          <button className="btn btn-with-icon btn-md btn-primary btn-founder-dashboard-level-up text-uppercase m-t-2">
            <i className="fa fa-arrow-right"/>
            Level Up
          </button>
        </div>
      </div>
    );
  }
}