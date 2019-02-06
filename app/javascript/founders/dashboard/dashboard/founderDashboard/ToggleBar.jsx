import React from "react";
import PropTypes from "prop-types";
import ToggleBarTab from "./ToggleBarTab";

export default class ToggleBar extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="d-flex justify-content-between justify-content-md-center founder-dashboard-togglebar__container">
        <div className="founder-dashboard-togglebar__toggle">
          <div
            className="btn-group founder-dashboard-togglebar__toggle-group"
            role="group"
          >
            <ToggleBarTab
              level={this.props.rootState.selectedLevel}
              rootProps={this.props.rootProps}
              rootState={this.props.rootState}
              setRootState={this.props.setRootState}
            />
            <ToggleBarTab
              level={this.props.rootProps.levels.find(level => {return level.number === 0;})}
              rootProps={this.props.rootProps}
              rootState={this.props.rootState}
              setRootState={this.props.setRootState}
            />
          </div>
        </div>
      </div>
    );
  }
}

ToggleBar.propTypes = {
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
