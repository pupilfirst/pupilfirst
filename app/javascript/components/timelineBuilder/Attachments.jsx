import React from "react";
import PropTypes from "prop-types";
import Attachment from "./Attachment";

export default class Attachments extends React.Component {
  render() {
    return (
      <div className="timeline-builder__attachments-container clearfix">
        {this.props.attachments.map(function(attachment, index) {
          return (
            <Attachment
              attachment={attachment}
              key={index}
              removeAttachmentCB={this.props.removeAttachmentCB}
            />
          );
        }, this)}
      </div>
    );
  }
}

Attachments.propTypes = {
  attachments: PropTypes.array,
  removeAttachmentCB: PropTypes.func
};
