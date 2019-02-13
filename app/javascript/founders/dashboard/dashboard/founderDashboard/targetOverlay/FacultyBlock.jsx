import React from "react";
import PropTypes from "prop-types";

export default class FacultyBlock extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="target-overlay__faculty-box px-4 mt-3">
        <span className="target-overlay__faculty-avatar mr-2">
          <img className="img-fluid" src={this.props.faculty.image_or_avatar_url} />
        </span>

        <h5 className="target-overlay__faculty-name m-0">
          <span className="target-overlay__faculty-name-headline">
            Assigned by:
          </span>

          <span className="font-regular">{this.props.faculty.name}</span>
        </h5>
      </div>
    );
  }
}

FacultyBlock.propTypes = {
  faculty: PropTypes.object.isRequired
};
