import React from "react";
import PropTypes from "prop-types";
import TargetsFilter from "./TargetsFilter";

export default class ActionBar extends React.Component {
  constructor(props) {
    super(props);

    this.startTour = this.startTour.bind(this);
  }

  componentDidMount() {
    if (this.props.rootState.tourDashboard) {
      this.props.setRootState({ tourDashboard: false }, () => {
        this.startTour();
      });
    }
  }

  startTour() {
    const startupShowTour = $("#dashboard-show-tour");
    let tour = introJs();

    tour.setOptions({
      skipLabel: "Close",
      steps: [
        {
          element: $(".founder-dashboard-header__container")[0],
          intro: startupShowTour.data("intro")
        },
        {
          element: $(".filter-targets-dropdown")[0],
          intro: startupShowTour.data("levelSelect")
        },
        {
          element: $(".founder-dashboard-target-group__box")[0],
          intro: startupShowTour.data("targetGroup")
        },
        {
          element: $(".founder-dashboard-target-header__container")[0],
          intro: startupShowTour.data("target")
        },
        {
          element: $(".founder-dashboard-target-status-badge__container")[0],
          intro: startupShowTour.data("targetStatus")
        },
        {
          intro: startupShowTour.data("finalMessage")
        }
      ]
    });

    tour.start();
  }

  render() {
    return (
      <div className="founder-dashboard-actionbar__container px-2 mx-auto pt-4 pt-md-5">
        <div className="founder-dashboard-actionbar__box d-flex justify-content-between">
          <TargetsFilter
            getAvailableTrackIds={this.props.getAvailableTrackIds}
            rootProps={this.props.rootProps}
            rootState={this.props.rootState}
            setRootState={this.props.setRootState}
          />

          <div className="d-flex">
            <div className="btn-group">
              <button
                className="btn btn-link founder-dashboard-actionbar__show-more-menu dropdown-toggle"
                data-toggle="dropdown"
                type="button"
              >
                <span className="founder-dashboard-actionbar__show-more-menu-dots" />
              </button>

              <div className="dropdown-menu filter-targets-dropdown__menu dropdown-menu-right">
                <a
                  onClick={this.startTour}
                  id="filter-targets-dropdown__tour-button"
                  className="dropdown-item filter-targets-dropdown__menu-item"
                  role="button"
                >
                  Take a Tour
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

ActionBar.propTypes = {
  getAvailableTrackIds: PropTypes.func.isRequired,
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
