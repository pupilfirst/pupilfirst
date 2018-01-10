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

  payableLabel() {
    if (_.isObject(this.props.rootState.coupon)) {
      return (
        <span>
          Your <strong>discounted</strong> fee is
        </span>
      );
    }

    return "You fee is";
  }

  isCouponApplied() {
    return _.isObject(this.props.rootState.coupon);
  }

  couponDiscount() {
    return this.props.rootState.coupon.discount;
  }

  couponSavings() {
    const fee = this.props.rootState.fee;
    return this.formatCurrency(fee.emiUndiscounted - fee.emi);
  }

  formatCurrency(fee) {
    return Number(fee).toLocaleString("en-in");
  }

  render() {
    const fee = this.props.rootState.fee;

    return (
      <div className="row justify-content-center mb-4">
        <div className="col-md-4 content-box text-center py-4" styleName="box">
          <div className="mb-4">
            <p>
              {this.payableLabel()} &#8377;{this.formatCurrency(fee.full)}.
              <br />
              You need to pay the following minimum EMI to proceed.
            </p>

            <div className="mt-3" styleName="amount-highlight">
              {this.isCouponApplied() && (
                <h5 className="font-semibold mb-0">
                  <del>&#8377;{this.formatCurrency(fee.emiUndiscounted)}</del>
                </h5>
              )}
              <h2 className="font-semibold mb-0">
                <span className="font-regular">&#8377;</span>
                {this.formatCurrency(fee.emi)}
              </h2>
              <p>for 2 founders</p>
              <div styleName="discount-details">
                {this.isCouponApplied() && (
                  <h6 styleName="discount-title">
                    DISCOUNT APPLIED
                    <p>
                      {this.couponDiscount()}% off (Discount Coupon)
                      <br />
                      <span className="dark-secondary">
                        You save &#8377;{this.couponSavings()}!
                      </span>
                    </p>
                  </h6>
                )}
                {!this.isCouponApplied() && (
                  <h6 styleName="discount-title">FULL PRICE</h6>
                )}
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
      </div>
    );
  }
}

FeeOffer.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
