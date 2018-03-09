import React from "react";
import PropTypes from "prop-types";

export default class FacultyBlock extends React.Component {
  constructor(props) {
    super(props);

    // Memoize a few items.
    this.faculty = this.getFaculty();
  }

  getFaculty() {
    const targetFaculty = this.props.target.faculty;

    if (_.isObject(targetFaculty)) {
      return _.find(this.props.rootProps.faculty, faculty => {
        return faculty.id === targetFaculty.id;
      });
    }
  }

  hasFaculty() {
    return _.isObject(this.faculty);
  }

  facultyName() {
    if (this.hasFaculty()) {
      return this.faculty.name;
    }

    return this.props.target.session_by;
  }

  faculty_target_relation() {
    if (_.isString(this.props.target.session_at)) {
      return "Session by:";
    } else {
      return "Assigned by:";
    }
  }

  render() {
    return (
      <div className="target-overlay__faculty-box">
        {this.hasFaculty() && (
          <span className="target-overlay__faculty-avatar mr-2">
            <img className="img-fluid" src={this.faculty.image_url} />
          </span>
        )}

        <h5 className="target-overlay__faculty-name m-0">
          <span className="target-overlay__faculty-name-headline">
            {this.faculty_target_relation()}
          </span>

          <span className="font-regular">{this.facultyName()}</span>
        </h5>
      </div>
    );
  }
}

FacultyBlock.propTypes = {
  target: PropTypes.object.isRequired
};
