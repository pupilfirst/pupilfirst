import React from "react";
import PropTypes from "prop-types";

export default class FacultyBlock extends React.Component {
  isFaculty() {
    return _.isObject(this.props.target.faculty);
  }

  facultyName() {
    if (this.isFaculty()) {
      return this.props.target.faculty.name;
    }

    return this.props.target.session_by;
  }

  faculty() {
    let faculty_target_relation = "Assigned by:";

    if (_.isString(this.props.target.session_at)) {
      faculty_target_relation = "Session by:";
    }

    return (
      <h5 className="target-overlay__faculty-name m-0">
        <span className="target-overlay__faculty-name-headline">
          {faculty_target_relation}
        </span>

        <span className="font-regular">{this.facultyName()}</span>
      </h5>
    );
  }

  render() {
    return (
      <div className="target-overlay__faculty-box">
        {this.isFaculty() && (
          <span className="target-overlay__faculty-avatar mr-2">
            <img
              className="img-fluid"
              src={this.props.target.faculty.image_url}
            />
          </span>
        )}

        {this.faculty()}
      </div>
    );
  }
}

FacultyBlock.propTypes = {
  target: PropTypes.object.isRequired
};
