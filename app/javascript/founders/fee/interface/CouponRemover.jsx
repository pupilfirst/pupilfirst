import React from "react";
import PropTypes from "prop-types";
import shared from "./shared.scss";
import styles from "./CouponRemover.scss";

export default class CouponRemover extends React.Component {
  render() {
    const coupon = this.props.rootState.coupon;

    return (
      <div className="p-1" styleName="shared.coupon-box">
        <div className="font-semibold" styleName="styles.message">
          Coupon with code{" "}
          <span className="dark-secondary" styleName="styles.code">
            {coupon.code}
          </span>{" "}
          applied!
          <p className="mt-2">You have unlocked {coupon.discount}% discount.</p>
        </div>

        {_.isString(coupon.instructions) && (
          <div className="mt-2">
            <p>
              <span className="font-semibold">Note: {coupon.instructions}</span>
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
