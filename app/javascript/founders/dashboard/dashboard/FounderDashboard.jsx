import React from "react";
import PropTypes from "prop-types";
import TimelineBuilder from "./TimelineBuilder";
import ToggleBar from "./founderDashboard/ToggleBar";
import Targets from "./founderDashboard/Targets";
import TargetOverlay from "./founderDashboard/TargetOverlay";
import ActionBar from "./founderDashboard/ActionBar";
import DashboardNotification from "./founderDashboard/DashboardNotification";

export default class FounderDashboard extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      targets: props.targets,
      selectedLevel: props.currentLevel,
      selectedTab: "selectedLevel",
      timelineBuilderVisible: false,
      timelineBuilderParams: {
        targetId: null
      },
      selectedTargetId: props.initialTargetId,
      tourDashboard: props.tourDashboard
    };

    this.setRootState = this.setRootState.bind(this);
    this.chooseTab = this.chooseTab.bind(this);
    this.closeTimelineBuilder = this.closeTimelineBuilder.bind(this);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
    this.handleTargetSubmission = this.handleTargetSubmission.bind(this);
    this.targetOverlayCloseCB = this.targetOverlayCloseCB.bind(this);
    this.selectTargetCB = this.selectTargetCB.bind(this);
    this.handlePopState = this.handlePopState.bind(this);
    this.hasSingleFounder = this.hasSingleFounder.bind(this);
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

  componentDidMount() {
    window.onpopstate = this.handlePopState;
  }

  handlePopState(event) {
    if (event.state.targetId) {
      this.setState({
        selectedTargetId: event.state.targetId
      });
    } else {
      this.setState({ selectedTargetId: null });
    }
  }

  chooseTab(tab) {
    this.setState({ activeTab: tab });
  }

  closeTimelineBuilder() {
    this.setState({ timelineBuilderVisible: false });
  }

  openTimelineBuilder(targetId) {
    let builderParams = {
      targetId: targetId || null
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
    updatedTargets[targetIndex].submitted_at = new moment();

    this.setState({
      targets: updatedTargets
    });
  }

  targetOverlayCloseCB() {
    this.setState({ selectedTargetId: null });
    history.pushState({}, "", "/student/dashboard");
  }

  selectTargetCB(targetId) {
    this.setState({ selectedTargetId: targetId });

    history.pushState(
      { targetId: targetId },
      "",
      "/student/dashboard/targets/" + targetId
    );
  }

  hasSingleFounder() {
    return this.props.founderDetails.length < 2;
  }

  levelZeroExists() {
    return (
      this.props.levels.filter(level => {
        return level.number === 0;
      }).length > 0
    );
  }

  render() {
    return (
      <div className="founder-dashboard-container pb-5">
        {this.levelZeroExists() && (
          <ToggleBar
            rootProps={this.props}
            rootState={this.state}
            setRootState={this.setRootState}
          />
        )}

        {(this.props.courseEnded ||
          this.props.levelUpEligibility !== "not_eligible") && (
          <DashboardNotification rootProps={this.props} />
        )}

        {this.state.selectedTab === "selectedLevel" && (
          <ActionBar
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
          hasSingleFounder={this.hasSingleFounder()}
        />

        {this.state.timelineBuilderVisible && (
          <TimelineBuilder
            testMode={this.props.testMode}
            authenticityToken={this.props.authenticityToken}
            targetSubmissionCB={this.handleTargetSubmission}
            closeTimelineBuilderCB={this.closeTimelineBuilder}
            targetId={this.state.timelineBuilderParams.targetId}
          />
        )}

        {_.isNumber(this.state.selectedTargetId) && (
          <TargetOverlay
            rootProps={this.props}
            rootState={this.state}
            setRootState={this.setRootState}
            iconPaths={this.props.iconPaths}
            targetId={this.state.selectedTargetId}
            founderDetails={this.props.founderDetails}
            closeCB={this.targetOverlayCloseCB}
            openTimelineBuilderCB={this.openTimelineBuilder}
            hasSingleFounder={this.hasSingleFounder()}
            courseEnded={this.props.courseEnded}
            questions={this.props.questions}
            communityPath={this.props.communityPath}
          />
        )}
      </div>
    );
  }
}

FounderDashboard.propTypes = {
  targets: PropTypes.array.isRequired,
  levels: PropTypes.array.isRequired,
  targetGroups: PropTypes.array.isRequired,
  currentLevel: PropTypes.object.isRequired,
  authenticityToken: PropTypes.string,
  levelUpEligibility: PropTypes.oneOf([
    "eligible",
    "cofounders_pending",
    "not_eligible",
    "date_locked"
  ]),
  iconPaths: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func,
  founderDetails: PropTypes.array,
  maxLevelNumber: PropTypes.number,
  initialTargetId: PropTypes.number,
  testMode: PropTypes.bool,
  tourDashboard: PropTypes.bool,
  courseEnded: PropTypes.bool,
  communityPath: PropTypes.string.isRequired
};
