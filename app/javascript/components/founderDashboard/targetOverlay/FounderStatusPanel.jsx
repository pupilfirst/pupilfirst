import React from "react";
import PropTypes from "prop-types";
import FounderBubble from "./FounderBubble";

export default class FounderStatusPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = { founderStatuses: this.setInitialStatuses() };
    this.updateStatus = this.updateStatus.bind(this);
  }

  componentDidMount() {
    let that = this;
    $.ajax({
      url: "/targets/" + that.props.targetId + "/founder_statuses",
      success: that.updateStatus
    });
  }

  updateStatus(response) {
    this.setState({ founderStatuses: response });
  }

  setInitialStatuses() {
    let initialStatuses = [];

    this.props.founderDetails.map(function(founderDetail) {
      let entry = {};
      entry[founderDetail.founderId] = "loading";
      initialStatuses.push(entry);
    });

    return initialStatuses;
  }

  render() {
    return (
      <div className="founder-dashboard__avatars ml-2">
        {this.state.founderStatuses.map(function(founderStatus) {
          let id = Object.keys(founderStatus)[0];
          let status = founderStatus[id];
          let founder = $.grep(this.props.founderDetails, function(e) {
            return e.founderId == id;
          })[0];
          let avatar = founder.avatar;

          return (
            <FounderBubble
              name={founder.founderName}
              avatar={avatar}
              status={status}
              key={id + "-" + this.props.targetId}
            />
          );
        }, this)}
      </div>
    );
  }
}

FounderStatusPanel.PropTypes = {
  founderDetails: PropTypes.array,
  targetId: PropTypes.number
};
