import React from "react";
import PropTypes from "prop-types";
import EventDetailsColumn from "./EventDetailsColumn";
import EventDescriptionColumn from "./EventDescriptionColumn";
import EventActionsColumn from "./EventActionsColumn";
import EventTargetRubric from "./EventTargetRubric";

export default class EventEntry extends React.Component {
  constructor(props) {
    super(props);

    this.showRubric = this.showRubric.bind(this);
  }

  showRubric() {
    let rubricVisible = this.props.rootState.reviewData[this.props.eventId][
      "rubricVisible"
    ];

    return _.isBoolean(rubricVisible) && rubricVisible;
  }

  render() {
    return (
      <div>
        <table className="review-dashboard__event-entry-table index">
          <tbody>
            <tr>
              <td>
                <EventDetailsColumn
                  eventId={this.props.eventId}
                  rootState={this.props.rootState}
                  setRootState={this.props.setRootState}
                />
              </td>
              <td>
                <EventDescriptionColumn eventData={this.props.eventData} />
              </td>
              <td style={{ width: "600px" }}>
                <EventActionsColumn
                  rootState={this.props.rootState}
                  setRootState={this.props.setRootState}
                  eventData={this.props.eventData}
                />
              </td>
            </tr>
            {this.props.eventData["rubric"] &&
              this.showRubric() && (
                <tr>
                  <td colSpan={3}>
                    <EventTargetRubric
                      rootState={this.props.rootState}
                      setRootState={this.props.setRootState}
                      rubric={this.props.eventData["rubric"]}
                    />
                  </td>
                </tr>
              )}
          </tbody>
        </table>
      </div>
    );
  }
}

EventEntry.propTypes = {
  rootState: PropTypes.object,
  setRootState: PropTypes.func,
  eventData: PropTypes.object,
  eventId: PropTypes.number
};
