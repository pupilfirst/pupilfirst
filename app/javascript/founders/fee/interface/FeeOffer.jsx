import React from "react";
import PropTypes from "prop-types";
import "./FeeOffer.scss";

export default class FeeOffer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      formStatus: "pending" // one of 'pending', 'inProgress', 'error'.
    };

    this.initiatePayment = this.initiatePayment.bind(this);
  }

  initiatePayment() {
    this.setState({ formStatus: "inProgress" });
    const that = this;
    setTimeout(() => {
      that.setState({ formStatus: "error" });
    }, 2000);
  }

  pluralizedPeriod() {
    if (this.props.period === 1) return "1 month";

    return `${this.props.period} months`;
  }

  containerClass() {
    return this.props.recommended ? "box-recommended" : "box";
  }

  render() {
    return (
      <div
        className="col-sm-4 content-box text-center"
        styleName={this.containerClass()}
      >
        {this.props.recommended && (
          <div styleName="recommended-notice">Recommended!</div>
        )}

        <h5
          className="font-semibold text-uppercase pb-2 mb-3"
          styleName="period"
        >
          {this.pluralizedPeriod()}
        </h5>
        <div className="my-4">
          <div styleName="amount-highlight">
            <h2 className="font-semibold mb-0">
              <span className="font-regular">₹</span>8000{" "}
            </h2>
            <p>for 2 founders</p>
            <div styleName="discount-details">
              <h6 styleName="discount-title">FULL PRICE</h6>
            </div>
          </div>
        </div>

        {this.state.formStatus === "pending" && (
          <div className="px-4">
            <button
              className="btn btn-md text-uppercase btn-with-icon btn-ghost-primary"
              onClick={this.initiatePayment}
            >
              Pay for {this.pluralizedPeriod()}
            </button>
          </div>
        )}

        {this.state.formStatus === "inProgress" && (
          <div className="px-4">
            <button className="btn btn-primary btn-md text-uppercase btn-with-icon disabled">
              <i className="fa fa-spinner fa-pulse" /> Please wait...
            </button>
          </div>
        )}

        {this.state.formStatus === "error" && (
          <div className="brand-danger mt-2">
            <i className="fa fa-warning" />
            <div className="font-semibold">Something went wrong!</div>
            Please refresh the page and try again.
          </div>
        )}
      </div>
    );
  }
}

FeeOffer.propTypes = {
  period: PropTypes.number.isRequired,
  recommended: PropTypes.bool.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
