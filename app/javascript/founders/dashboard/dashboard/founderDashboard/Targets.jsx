import React from "react";
import PropTypes from "prop-types";
import TargetCollection from "./TargetCollection";

export default class Targets extends React.Component {
  targetGroups() {
    let activeTrackId = null;

    if (this.props.rootState.activeTrackId !== "default") {
      activeTrackId = this.props.rootState.activeTrackId;
    }

    // Return target groups that are in the selected track.
    return _.filter(this.props.rootProps.targetGroups, targetGroup => {
      if (targetGroup.level.id !== this.props.rootState.chosenLevelId) {
        return false;
      }

      if (activeTrackId === null) {
        return !_.isObject(targetGroup.track);
      } else {
        return targetGroup.track.id === activeTrackId;
      }
    });
  }

  targetCollections() {
    let collectionLength = this.targetGroups().length;

    return this.targetGroups().map((targetGroup, targetGroupIndex) => {
      let finalCollection = collectionLength === targetGroupIndex + 1;

      return (
        <TargetCollection
          key={targetGroup.id}
          targetGroupId={targetGroup.id}
          finalCollection={finalCollection}
          rootProps={this.props.rootProps}
          rootState={this.props.rootState}
          setRootState={this.props.setRootState}
          selectTargetCB={this.props.selectTargetCB}
        />
      );
    }, this);
  }

  render() {
    return <div>{this.targetCollections()}</div>;
  }
}

Targets.propTypes = {
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired,
  selectTargetCB: PropTypes.func.isRequired
};
