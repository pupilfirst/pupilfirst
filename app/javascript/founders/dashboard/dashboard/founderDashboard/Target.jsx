import React from "react";
import PropTypes from "prop-types";
import TargetHeader from "./TargetHeader";

export default class Target extends React.Component {
  render() {
    return (
      <div className="founder-dashboard-target__container">
        <TargetHeader
          targetId={this.props.targetId}
          rootProps={this.props.rootProps}
          rootState={this.props.rootState}
          setRootState={this.props.setRootState}
          selectTargetCB={this.props.selectTargetCB}
          hasSingleFounder={this.props.hasSingleFounder}
        />
      </div>
    );
  }
}

Target.propTypes = {
  targetId: PropTypes.number,
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired,
  selectTargetCB: PropTypes.func.isRequired,
  hasSingleFounder: PropTypes.bool
};
