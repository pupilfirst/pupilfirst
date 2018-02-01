import React from "react";
import PropTypes from "prop-types";
import TargetHeader from "./TargetHeader";

export default class Target extends React.Component {
  render() {
    return (
      <div className="founder-dashboard-target__container">
        <TargetHeader
          onClickCB={this.props.selectTargetCB}
          target={this.props.target}
          displayDate={this.props.displayDate}
          iconPaths={this.props.iconPaths}
          currentLevel={this.props.currentLevel}
        />
      </div>
    );
  }
}

Target.propTypes = {
  currentLevel: PropTypes.number,
  target: PropTypes.object,
  displayDate: PropTypes.bool,
  iconPaths: PropTypes.object,
  selectTargetCB: PropTypes.func
};
