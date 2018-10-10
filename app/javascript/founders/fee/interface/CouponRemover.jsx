import React from "react";
import PropTypes from "prop-types";
import shared from "./shared.module.scss";
import styles from "./CouponRemover.module.scss";

export default class CouponRemover extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      removing: false,
      errorText: null
    };

    this.removeCoupon = this.removeCoupon.bind(this);
  }

  removeCoupon(event) {
    event.preventDefault();

    this.setState({ removing: true }, () => {
      $.ajax("/admissions/coupon_remove", {
        method: "PATCH"
      })
        .done(data => {
          const updatedState = _.merge(data, { hasCouponError: false });
          this.setState({ removing: false });
          this.props.setRootState(updatedState);
        })
        .fail(() => {
          this.props.setRootState({ hasCouponError: true }, () => {
            setTimeout(() => {
              location.reload();
            }, 1000);
          });
        });
    });
  }

  render() {
    const coupon = this.props.rootState.coupon;

    return (
      <div className="p-1" styleName="shared.coupon-box">
        <div className="font-semibold" styleName="styles.message">
          Code{" "}
          <span className="dark-secondary" styleName="styles.code">
            {coupon.code}
          </span>{" "}
          applied!
        </div>

        {_.isString(coupon.instructions) && (
          <div className="mt-2">
            <p>
              <span className="font-semibold">Note:</span> {coupon.instructions}
            </p>
          </div>
        )}

        {!this.state.removing && (
          <button
            className="btn btn-ghost-secondary btn-sm text-uppercase mt-2"
            onClick={this.removeCoupon}
          >
            Remove
          </button>
        )}

        {this.state.removing && (
          <button className="btn btn-secondary btn-sm text-uppercase mt-2 btn-with-icon disabled">
            <i className="fa fa-spinner fa-pulse" /> Removing
          </button>
        )}
      </div>
    );
  }
}

CouponRemover.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
