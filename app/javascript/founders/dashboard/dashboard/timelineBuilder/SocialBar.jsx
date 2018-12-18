import React from "react";
import PropTypes from "prop-types";
import TextAreaCounter from "./TextAreaCounter";

// TODO: Move TextAreaCounter to TimelineBuilder and remove Social Bar
export default class SocialBar extends React.Component {
  render() {
    return (
      <div className="timeline-builder__social-bar clearfix">
        <TextAreaCounter description={this.props.description} />
      </div>
    );
  }
}

SocialBar.propTypes = {
  description: PropTypes.string
};
