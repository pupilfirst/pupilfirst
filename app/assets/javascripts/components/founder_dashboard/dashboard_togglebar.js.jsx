class FounderDashboardToggleBar extends React.Component {

  render() {
    return (
      <div className="founder-dashboard-togglebar__container">
        <div className="founder-dashboard-togglebar__toggle">
          <div className="btn-group founder-dashboard-togglebar__toggle-group" data-toggle="buttons">
            <label className="btn founder-dashboard-togglebar__toggle-btn btn-md active m-a-0">
              <input type="radio" name="toggle-options" id="toggle-option1" autocomplete="off" checked/>TARGETS
            </label>
            <label className="btn founder-dashboard-togglebar__toggle-btn btn-md m-a-0">
              <span className="badge badge-pill badge-primary founder-dashboard-togglebar__toggle-btn-notify">
                20
              </span>
              <input type="radio" name="toggle-options" id="toggle-option2" autocomplete="off"/>CHORES
            </label>
            <label className="btn founder-dashboard-togglebar__toggle-btn btn-md m-a-0">
              <span className="badge badge-pill badge-primary founder-dashboard-togglebar__toggle-btn-notify">
                2
              </span>
              <input type="radio" name="toggle-options" id="toggle-option3" autocomplete="off"/>SESSIONS
            </label>
          </div>
        </div>
        <div className="founder-dashboard-add-event__container pull-xs-right hidden-md-up">
          <button id="#add-event-button" className="btn btn-md btn-secondary text-uppercase founder-dashboard-add-event__btn js-founder-dashboard__trigger-builder" data-toggle="modal">
            <i className="fa fa-plus"/>
          </button>
        </div>
      </div>
    );
  }
}