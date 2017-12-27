import React from "react";
import PropTypes from "prop-types";

export default class BillingAddressForm extends React.Component {
  stateOptions() {}

  render() {
    return (
      <div className="content-box">
        <div className="form-group">
          <label
            className="form-control-label"
            htmlFor="founders_billing_billing_address"
          >
            Billing address
          </label>
          <textarea
            required="required"
            placeholder="House Number,
                Street Name,
                Locality,
                City.
                "
            rows="4"
            className="form-control"
            name="founders_billing[billing_address]"
            id="founders_billing_billing_address"
          />
        </div>
        <div className="form-group">
          <label
            className="col-form-label form-control-label"
            htmlFor="founders_billing_billing_state_id"
          >
            Billing state
          </label>
          <select
            required="required"
            className="form-control"
            name="founders_billing[billing_state_id]"
            id="founders_billing_billing_state_id"
          >
            <option value="">Select your State</option>
            <option value="1">Karnataka</option>
            {this.stateOptions()}
          </select>
        </div>
      </div>
    );
  }
}

BillingAddressForm.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
