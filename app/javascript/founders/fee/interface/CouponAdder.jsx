import React from "react";
import PropTypes from "prop-types";
import "./CouponAdder.scss";

export default class CouponAdder extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      formVisible: false
    };

    this.showForm = this.showForm.bind(this);
    this.hideForm = this.hideForm.bind(this);
  }

  showForm() {
    this.setState({ formVisible: true });
  }

  hideForm() {
    this.setState({ formVisible: false });
  }

  form() {
    return (
      <div
        className="discount-coupon__box discount-coupon__box--form simple-form-container p-3"
        id="coupon-form"
      >
        <form
          className="simple_form new_admissions_coupon"
          id="new_admissions_coupon"
          method="post"
        >
          <div className="form-group string required admissions_coupon_code">
            <input
              className="form-control string required"
              autoFocus={true}
              required="required"
              placeholder="Enter Code"
              type="text"
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
        className="discount-coupon__box brand-secondary font-semibold p-3"
        styleName="cover-button"
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
