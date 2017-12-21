import React from "react";
import PropTypes from "prop-types";
import FacebookShareToggleButton from "./FacebookShareToggleButton";
import TextAreaCounter from "./TextAreaCounter";

export default class SocialBar extends React.Component {
  render() {
    return (
      <div className="timeline-builder__social-bar clearfix">
        <FacebookShareToggleButton
          facebookShareEligibility={this.props.facebookShareEligibility}
        />
        <TextAreaCounter description={this.props.description} />
      </div>
    );
  }
}

SocialBar.propTypes = {
  description: PropTypes.string,
  facebookShareEligibility: PropTypes.string
};
