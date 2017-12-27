import React from "react";
import PropTypes from "prop-types";

export default class CouponAdder extends React.Component {
  render() {
    return (
      <div>
        <div
          id="coupon-form-show"
          className="discount-coupon__box discount-coupon__box--show brand-secondary font-semibold p-a-1"
        >
          <h4 className="font-semibold dark-secondary m-a-0">
            Do you have a coupon?
          </h4>
        </div>

        <div
          id="coupon-form"
          className="discount-coupon__box discount-coupon__box--form simple-form-container hidden-xs-up p-a-1"
        >
          <form
            className="simple_form new_admissions_coupon"
            action="/admissions/coupon_submit"
            acceptCharset="UTF-8"
          >
            <div className="form-group string required admissions_coupon_code">
              <input
                className="form-control string required"
                autoFocus="autofocus"
                required="required"
                aria-required="true"
                placeholder="Enter Code"
                type="text"
                name="admissions_coupon[code]"
                id="admissions_coupon_code"
              />
            </div>
            <div
              className="coupon-form-hide btn btn-ghost-secondary btn-sm text-uppercase m-r-1 discount-coupon__box-btn"
              id="coupon-form-hide"
            >
              Hide
            </div>
            <input
              type="submit"
              name="commit"
              value="Apply Code"
              className="btn btn-secondary btn-sm text-uppercase discount-coupon__box-btn"
              data-disable-with="Apply Code"
            />
          </form>
        </div>
      </div>
    );
  }
}

CouponAdder.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
