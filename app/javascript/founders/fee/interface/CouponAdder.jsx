import React from "react";
import PropTypes from "prop-types";
import styles from "./CouponAdder.scss";
import shared from "./shared.scss";

export default class CouponAdder extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      formVisible: false,
      couponCode: ""
    };

    this.showForm = this.showForm.bind(this);
    this.hideForm = this.hideForm.bind(this);
    this.submit = this.submit.bind(this);
    this.updateCouponCode = this.updateCouponCode.bind(this);
  }

  showForm() {
    this.setState({ formVisible: true });
  }

  hideForm() {
    this.setState({ formVisible: false });
  }

  submit(event) {
    event.preventDefault();

    $.ajax("/admissions/coupon_submit", {
      data: { admissions_coupon: { code: this.state.couponCode } },
      method: "POST"
    })
      .done(data => {
        debugger;
      })
      .fail(() => {});
  }

  updateCouponCode(event) {
    const code = event.target.value;
    this.setState({ couponCode: code });
  }

  form() {
    return (
      <div className="p-3" styleName="shared.coupon-box">
        <form onSubmit={this.submit}>
          <div className="form-group string required">
            <input
              className="form-control string required"
              autoFocus={true}
              required="required"
              placeholder="Enter Code"
              type="text"
              value={this.state.couponCode}
              onChange={this.updateCouponCode}
            />
          </div>
          <div
            className="btn btn-ghost-secondary btn-sm text-uppercase mr-2 mb-3 mb-md-0"
            onClick={this.hideForm}
          >
            Hide
          </div>
          <button
            type="submit"
            className="btn btn-secondary btn-sm text-uppercase mb-3 mb-md-0"
          >
            Apply Code
          </button>
        </form>
      </div>
    );
  }

  coverButton() {
    return (
      <div
        className="brand-secondary font-semibold p-3"
        styleName="shared.coupon-box styles.cover-button"
        onClick={this.showForm}
      >
        <h4 className="font-semibold dark-secondary m-0">
          Do you have a coupon?
        </h4>
      </div>
    );
  }

  render() {
    if (this.state.formVisible) {
      return this.form();
    } else {
      return this.coverButton();
    }
  }
}

CouponAdder.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
