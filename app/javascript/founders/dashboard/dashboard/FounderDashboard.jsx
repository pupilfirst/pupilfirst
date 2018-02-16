import React from "react";
import PropTypes from "prop-types";
import TimelineBuilder from "./TimelineBuilder";
import ToggleBar from "./founderDashboard/ToggleBar";
import Targets from "./founderDashboard/Targets";
import TargetOverlay from "./founderDashboard/TargetOverlay";
import ActionBar from "./founderDashboard/ActionBar";
import LevelUpNotification from "./founderDashboard/LevelUpNotification";

export default class FounderDashboard extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      targets: props.targets,
      chosenLevelId: props.currentLevel.id,
      timelineBuilderVisible: false,
      timelineBuilderParams: {
        targetId: null,
        selectedTimelineEventTypeId: null
      },
      selectedTarget: this.targetDetails(props.initialTargetId, true)
    };

    // Pick initial track from list of computed track IDs.
    this.state.activeTrackId = this.availableTrackIds()[0];

    this.setRootState = this.setRootState.bind(this);
    this.chooseTab = this.chooseTab.bind(this);
    this.closeTimelineBuilder = this.closeTimelineBuilder.bind(this);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
    this.handleTargetSubmission = this.handleTargetSubmission.bind(this);
    this.targetOverlayCloseCB = this.targetOverlayCloseCB.bind(this);
    this.selectTargetCB = this.selectTargetCB.bind(this);
    this.handlePopState = this.handlePopState.bind(this);
    this.availableTrackIds = this.availableTrackIds.bind(this);
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

  availableTrackIds(levelId = null) {
    if (levelId === null) {
      levelId = this.state.chosenLevelId;
    }

    let targetGroupsInLevel = this.props.targetGroups.filter(targetGroup => {
      return targetGroup.level.id === levelId;
    });

    let availableTrackIds = _.uniq(
      targetGroupsInLevel.map(targetGroup => {
        if (_.isObject(targetGroup.track)) {
          return targetGroup.track.id;
        } else {
          return "default";
        }
      })
    );

    let sortedTracks = _.sortBy(this.props.tracks, ["sort_index"]);

    let filteredAndSortedTracks = _.filter(sortedTracks, track => {
      return availableTrackIds.includes(track.id);
    });

    let sortedTrackIds = filteredAndSortedTracks.map(track => {
      return track.id;
    });

    if (availableTrackIds.includes("default")) {
      return ["default"].concat(sortedTrackIds);
    }

    return sortedTrackIds;
  }

  componentDidMount() {
    window.onpopstate = this.handlePopState;
  }

  handlePopState(event) {
    if (event.state.targetId) {
      this.setState({
        selectedTarget: this.targetDetails(event.state.targetId)
      });
    } else {
      this.setState({ selectedTarget: null });
    }
  }

  chooseTab(tab) {
    this.setState({ activeTab: tab });
  }

  closeTimelineBuilder() {
    this.setState({ timelineBuilderVisible: false });
  }

  openTimelineBuilder(targetId, selectedTimelineEventTypeId) {
    let builderParams = {
      targetId: targetId || null,
      selectedTimelineEventTypeId: selectedTimelineEventTypeId || null
    };

    this.setState({
      timelineBuilderVisible: true,
      timelineBuilderParams: builderParams
    });
  }

  handleTargetSubmission(targetId) {
    let updatedTargets = _.cloneDeep(this.state.targets);

    let targetIndex = _.findIndex(updatedTargets, ["id", targetId]);

    if (targetIndex === -1) {
      console.error(
        "Could not find target with ID " +
          targetId +
          " in list of known targets."
      );

      return;
    }

    updatedTargets[targetIndex].status = "submitted";

    let updatedSelectedTarget = _.cloneDeep(this.state.selectedTarget);

    if (
      this.state.selectedTarget &&
      targetId === this.state.selectedTarget.id
    ) {
      updatedSelectedTarget.status = "submitted";
    }

    this.setState({
      targets: updatedTargets,
      selectedTarget: updatedSelectedTarget
    });
  }

  targetOverlayCloseCB() {
    this.setState({ selectedTarget: null });
    history.pushState({}, "", "/founder/dashboard");
  }

  targetDetails(targetId, loadFromProps = false) {
    if (loadFromProps) {
    } else {
      return _.find(this.state.targets, ["id", targetId]);
    }
  }

  selectTargetCB(targetId) {
    this.setState({ selectedTarget: this.targetDetails(targetId) });

    history.pushState(
      { targetId: targetId },
      "",
      "/founder/dashboard/targets/" + targetId
    );
  }

  render() {
    return (
      <div className="founder-dashboard-container pb-5">
        <ToggleBar
          availableTrackIds={this.availableTrackIds()}
          rootProps={this.props}
          rootState={this.state}
          setRootState={this.setRootState}
        />

        {this.props.levelUpEligibility !== "not_eligible" && (
          <LevelUpNotification rootProps={this.props} />
        )}

        {this.props.currentLevel !== 0 && (
          <ActionBar
            getAvailableTrackIds={this.availableTrackIds}
            rootProps={this.props}
            rootState={this.state}
            setRootState={this.setRootState}
          />
        )}

        <Targets
          rootProps={this.props}
          rootState={this.state}
          setRootState={this.setRootState}
          selectTargetCB={this.selectTargetCB}
        />

        {this.state.timelineBuilderVisible && (
          <TimelineBuilder
            timelineEventTypes={this.props.timelineEventTypes}
            facebookShareEligibility={this.props.facebookShareEligibility}
            testMode={this.props.testMode}
            authenticityToken={this.props.authenticityToken}
            targetSubmissionCB={this.handleTargetSubmission}
            closeTimelineBuilderCB={this.closeTimelineBuilder}
            targetId={this.state.timelineBuilderParams.targetId}
            selectedTimelineEventTypeId={
              this.state.timelineBuilderParams.selectedTimelineEventTypeId
            }
          />
        )}

        {this.state.selectedTarget && (
          <TargetOverlay
            rootProps={this.props}
            iconPaths={this.props.iconPaths}
            target={this.state.selectedTarget}
            founderDetails={this.props.founderDetails}
            closeCB={this.targetOverlayCloseCB}
            openTimelineBuilderCB={this.openTimelineBuilder}
          />
        )}
      </div>
    );
  }
}

FounderDashboard.propTypes = {
  targets: PropTypes.array.isRequired,
  levels: PropTypes.array.isRequired,
  faculty: PropTypes.array.isRequired,
  targetGroups: PropTypes.array.isRequired,
  tracks: PropTypes.array.isRequired,
  currentLevel: PropTypes.object.isRequired,
  timelineEventTypes: PropTypes.object,
  facebookShareEligibility: PropTypes.string,
  authenticityToken: PropTypes.string,
  levelUpEligibility: PropTypes.oneOf([
    "eligible",
    "cofounders_pending",
    "not_eligible"
  ]),
  iconPaths: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func,
  founderDetails: PropTypes.array,
  maxLevelNumber: PropTypes.number,
  initialTargetId: PropTypes.number,
  testMode: PropTypes.bool
};
