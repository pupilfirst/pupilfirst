import React from "react";
import PropTypes from "prop-types";
import EventEntry from "./eventsReviewDashboard/EventEntry";

export default class EventsReviewDashboard extends React.Component {
  constructor(props) {
    super(props);

    this.state = { reviewData: this.props.reviewData, selectedScope: "all" };

    this.changeScope = this.changeScope.bind(this);
    this.setRootState = this.setRootState.bind(this);
  }

  setRootState(updater, callback) {
    // newState can be object or function!
    this.setState(updater, () => {
      if (this.props.debug) {
        console.log("setRootState", JSON.stringify(this.state));
      }

      if (callback) {
        callback();
      }
    });
  }

  scopeClasses(scope) {
    let classNames = "scope";
    if (scope === this.state.selectedScope) {
      classNames += " selected";
    }
    return classNames;
  }

  changeScope(event) {
    this.setState({ selectedScope: event.target.dataset["value"] });
  }

  scopedReviewData() {
    let data = this.state.reviewData;
    if (this.state.selectedScope !== "all") {
      data = this.filterData(data, this.state.selectedScope);
    }
    return data;
  }

  filterData(data, scope) {
    let dataClone = $.extend(true, {}, data);

    for (let key in dataClone) {
      if (dataClone[key]["level_scope"] !== scope) {
        delete dataClone[key];
      }
    }

    return dataClone;
  }

  admittedCount() {
    return Object.keys(this.filterData(this.state.reviewData, "admitted"))
      .length;
  }

  levelZeroCount() {
    return Object.keys(this.filterData(this.state.reviewData, "levelZero"))
      .length;
  }

  render() {
    return (
      <div>
        <h3>
          {" "}
          Total events pending review:{" "}
          {Object.keys(this.state.reviewData).length}
        </h3>
        <div className="table_tools">
          <ul className="scopes table_tools_segmented_control">
            <li className={this.scopeClasses("all")}>
              <a
                className="table_tools_button"
                data-value="all"
                onClick={this.changeScope}
              >
                All
              </a>
            </li>
            <li className={this.scopeClasses("admitted")}>
              <a
                className="table_tools_button"
                data-value="admitted"
                onClick={this.changeScope}
              >
                {"From Admitted Startups (" + this.admittedCount() + ")"}
              </a>
            </li>
            <li className={this.scopeClasses("levelZero")}>
              <a
                className="table_tools_button"
                data-value="levelZero"
                onClick={this.changeScope}
              >
                {"From Level 0 Startups (" + this.levelZeroCount() + ")"}
              </a>
            </li>
          </ul>
        </div>
        <table>
          <tbody>
            <tr>
              <td>
                {Object.keys(this.scopedReviewData()).map(function(eventId) {
                  return (
                    <EventEntry
                      rootState={this.state}
                      setRootState={this.setRootState}
                      eventData={this.state.reviewData[eventId]}
                      key={eventId}
                      eventId={parseInt(eventId)}
                    />
                  );
                }, this)}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    );
  }
}

EventsReviewDashboard.propTypes = {
  reviewData: PropTypes.object,
  debug: PropTypes.bool
};
