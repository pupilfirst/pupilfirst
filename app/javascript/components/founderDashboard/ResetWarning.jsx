import React from "react";

export default class RestartWarning extends React.Component {
  render() {
    return (
      <div className="founder-dashboard_restart-warning-container px-3 mx-auto">
        <div className="alert alert-warning">
          <span>
            <i className="fa fa-exclamation-triangle" aria-hidden="true" />
            &nbsp;Your startup has requested for a pivot! We advise you to wait
            for its approval before completing further tasks.
          </span>
        </div>
      </div>
    );
  }
}
