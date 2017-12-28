import React from "react";
import PropTypes from "prop-types";

export default class CouponRemover extends React.Component {
  couponCode() {
    return "APPLIEDCODE";
  }

  couponInstructions() {
    return "These are some instructions that need to be followed when using this coupon.";
  }

  couponBenefit() {
    return "30 days free";
  }

  render() {
    return (
      <div className="discount-coupon__box discount-coupon-applied-box p-1">
        <div className="discount-coupon-applied-box__message font-semibold">
          Coupon with code{" "}
          <span className="discount-coupon-applied--code dark-secondary">
            {this.couponCode()}
          </span>
          applied!
          <p className="mt-2">You have unlocked {this.couponBenefit()}.</p>
        </div>

        {_.isString(this.couponInstructions()) && (
          <div className="coupon-instructions mt-2">
            <p>
              <span className="font-semibold">
                Note:
                {this.couponInstructions()}
              </span>
            </p>
          </div>
        )}

        <button className="btn btn-ghost-secondary btn-sm text-uppercase mt-2">
          Remove
        </button>
      </div>
    );
  }
}

CouponRemover.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
