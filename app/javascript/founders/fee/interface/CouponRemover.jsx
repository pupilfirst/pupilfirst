import React from "react";
import PropTypes from "prop-types";

export default class CouponRemover extends React.Component {
  render() {
    return (
      <div className="discount-coupon__box discount-coupon-applied-box p-a-1">
        <p className="discount-coupon-applied-box__message font-semibold">
          Coupon with code
          <span className="discount-coupon-applied--code dark-secondary">
            {this.couponCode()} applied!
          </span>
          <p className="m-t-1">You have unlocked {this.couponBenefit()}.</p>
        </p>

        {_.isString(this.couponInstructions()) && (
          <div className="coupon-instructions m-t-1">
            <p>
              <span className="font-semibold">
                Note:
                {this.couponInstructions()}
              </span>
            </p>
          </div>
        )}

        {this.removeCouponButton()}
      </div>
    );
  }
}

CouponRemover.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
