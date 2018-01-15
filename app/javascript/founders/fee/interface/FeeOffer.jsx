import React from "react";
import PropTypes from "prop-types";
import CouponAdder from "./CouponAdder";
import CouponRemover from "./CouponRemover";
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
    if (this.hasBillingAddress() && this.hasBillingState()) {
      this.setState({ formStatus: "inProgress" }, () => {
        const that = this;

        setTimeout(() => {
          that.setState({ formStatus: "error" });
        }, 2000);
      });
    } else {
      this.props.setRootState({ highlightBillingAddressErrors: true });
    }
  }

  hasBillingAddress() {
    const address = this.props.rootState.startup.billingAddress;
    return _.isString(address) && address.length > 0;
  }

  hasBillingState() {
    return _.isFinite(this.props.rootState.startup.billingStateId);
  }

  totalFee() {
    const fee = this.props.rootState.fee;

    if (_.isObject(this.props.rootState.coupon)) {
      return (
        <span>
          <s>&#8377;{this.formatCurrency(fee.originalFee)}</s> &#8377;{this.formatCurrency(
            fee.discountedFee
          )}
        </span>
      );
    }

    return <span>&#8377;{this.formatCurrency(fee.originalFee)}</span>;
  }

  isCouponApplied() {
    return _.isObject(this.props.rootState.coupon);
  }

  couponDiscount() {
    return this.props.rootState.coupon.discount;
  }

  formatCurrency(fee) {
    return Number(fee).toLocaleString("en-in");
  }

  render() {
    const fee = this.props.rootState.fee;

    return (
      <div className="content-box text-center py-4" styleName="box">
        <div className="mb-4">
          <p>
            Your fee is {this.totalFee()}.
            <br />
            {!this.isCouponApplied() && (
              <span>You need to pay the following minimum EMI to proceed:</span>
            )}
            {this.isCouponApplied() && (
              <span>Your EMI after applying the coupon is:</span>
            )}
          </p>

          <div className="mt-3" styleName="amount-highlight">
            <h2 className="font-semibold mb-0">
              <span className="font-regular">&#8377;</span>
              {this.formatCurrency(fee.emi)}
            </h2>
            <p>for 2 founders</p>
            <div styleName="discount-details">
              {this.isCouponApplied() && (
                <h6 className="text-uppercase" styleName="discount-title">
                  Coupon applied
                  <p>
                    {this.couponDiscount()}% off
                    <br />
                  </p>
                </h6>
              )}
              {!this.isCouponApplied() && (
                <h6 styleName="discount-title">FULL PRICE</h6>
              )}

              <div
                className="text-center mx-auto mt-3"
                styleName="coupon-form-container"
              >
                {this.isCouponApplied() && (
                  <CouponRemover
                    rootState={this.props.rootState}
                    setRootState={this.props.setRootState}
                  />
                )}
                {!this.isCouponApplied() && (
                  <CouponAdder
                    rootState={this.props.rootState}
                    setRootState={this.props.setRootState}
                  />
                )}

                {this.props.rootState.hasCouponError && (
                  <div className="alert alert-warning mt-2" role="alert">
                    Oops! Something went wrong.
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {this.state.formStatus === "pending" && (
          <div className="px-4">
            <button
              className="btn btn-md text-uppercase btn-with-icon btn-ghost-primary"
              onClick={this.initiatePayment}
            >
              Pay Now
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
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
