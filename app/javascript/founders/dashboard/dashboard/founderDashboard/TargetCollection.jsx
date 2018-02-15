import React from "react";
import PropTypes from "prop-types";
import Target from "./Target";

export default class TargetCollection extends React.Component {
  targets() {
    let groupTargets = this.targetsForGroup();

    if (groupTargets.length < 1) {
      return (
        <div className="founder-dashboard-target-noresult text-center py-3">
          <img
            className="founder-dashboard-target-noresult__icon mx-auto"
            src={this.props.rootProps.iconPaths.noResults}
          />
          <h4 className="default mt-3 font-semibold">No results to display!</h4>
        </div>
      );
    } else {
      return groupTargets.map(target => {
        return (
          <Target
            key={target.id}
            targetId={target.id}
            rootProps={this.props.rootProps}
            rootState={this.props.rootState}
            setRootState={this.props.setRootState}
            selectTargetCB={this.props.selectTargetCB}
          />
        );
      }, this);
    }
  }

  targetsForGroup() {
    let targetGroupId = this.props.targetGroupId;

    return _.filter(this.props.rootState.targets, target => {
      return target.target_group.id === targetGroupId;
    });
  }

  containerClasses() {
    let classes = "founder-dashboard-target-group__container px-2 mx-auto";

    if (this.props.finalCollection) {
      classes += " founder-dashboard-target-group__container--final";
    }

    return classes;
  }

  render() {
    let targetGroup = _.find(this.props.rootProps.targetGroups, [
      "id",
      this.props.targetGroupId
    ]);

    return (
      <div className={this.containerClasses()}>
        <div className="founder-dashboard-target-group__box">
          <div className="founder-dashboard-target-group__header pb-4 px-3 text-center">
            {targetGroup.milestone && (
              <div className="founder-dashboard-target-group__milestone-label text-uppercase font-semibold">
                Milestone Targets
              </div>
            )}

            <h3 className="font-semibold mt-4 mb-0">{this.props.name}</h3>

            {_.isString(targetGroup.description) && (
              <p className="founder-dashboard-target-group__header-info">
                {targetGroup.description}
              </p>
            )}
          </div>

          {this.targets()}
        </div>
      </div>
    );
  }
}

TargetCollection.propTypes = {
  targetGroupId: PropTypes.number.isRequired,
  finalCollection: PropTypes.bool.isRequired,
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired,
  selectTargetCB: PropTypes.func.isRequired
};

TargetCollection.defaultProps = {
  milestone: false,
  finalCollection: false
};
