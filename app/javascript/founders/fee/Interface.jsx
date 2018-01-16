import * as React from "react";
import PropTypes from "prop-types";
import FeeOffer from "./interface/FeeOffer";
import BillingAddressForm from "./interface/BillingAddressForm";

import "./Interface.scss";

export default class Interface extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      coupon: props.coupon,
      fee: props.fee,
      startup: props.startup,
      hasCouponError: false,
      highlightBillingAddressErrors: false
    };

    this.setRootState = this.setRootState.bind(this);
  }

  setRootState(updater, callback) {
    // newState can be object or function!
    this.setState(updater, () => {
      if (this.props.debug) {
        console.log("setRootState", JSON.stringify(this.state));
      }

      if (callback) {
        callback();
      }
    });
  }

  mailTo(emailAddress) {
    return <a href={"mailto:" + emailAddress}>{emailAddress}</a>;
  }

  billingFoundersCount() {
    return 2;
  }

  couponApplied() {
    return _.isObject(this.state.coupon);
  }

  bannerMessages() {
    const [heading, subheading] = (disabled => {
      if (disabled) {
        return [
          "Temporarily Disabled",
          "Fee payments have been temporarily disabled."
        ];
      }

      return ["Membership Fee", "Payment pending"];
    })(this.props.disabled);

    return [
      <h1 key="heading">{heading}</h1>,
      <h4 key="subheading" className="mx-auto">
        {subheading}
      </h4>
    ];
  }

  primaryMessages() {
    if (this.props.disabled) {
      return (
        <div>
          <h3 className="text-center mb-2">
            You cannot make payments{" "}
            <span className="brand-secondary font-semibold">at this time.</span>
          </h3>
          <ul styleName="important-points">
            <li>
              If you need any help please contact us on Slack or mail us at{" "}
              {this.mailTo("help@sv.co")}.
            </li>
          </ul>
        </div>
      );
    } else {
      return (
        <div>
          <h3 className="text-center mb-2">
            <span className="brand-secondary font-semibold">
              Please pay the membership fee to continue.
            </span>
          </h3>
          <ul styleName="important-points">
            <li>
              It covers your team of{" "}
              <strong>{this.billingFoundersCount()} founders</strong>.
            </li>
            <li>
              You can change your team at any time. Just reach us on{" "}
              {this.mailTo("help@sv.co")}.
            </li>
          </ul>
        </div>
      );
    }
  }

  render() {
    return (
      <div>
        <div className="secondary-banner">
          <div className="container">
            <div className="text-center">{this.bannerMessages()}</div>
          </div>
        </div>

        <div className="container">
          <div className="row my-4 justify-content-center">
            <div className="col-lg-7">
              <div className="content-box mb-3">
                {this.primaryMessages()}

                {this.props.paymentRequested && (
                  <div className="alert alert-warning mt-2">
                    <i className="fa fa-warning" /> It looks like you've
                    attempted to pay at least once before, but didn&rsquo;t
                    complete the process. Note that it might take a few minutes
                    for the payment status to update, if you experienced network
                    issues after completing the payment. Please contact us at{" "}
                    {this.mailTo("help@sv.co")} if you&rsquo;re experiencing any
                    issue.
                  </div>
                )}

                <h3>Alternate payment methods</h3>

                <p>
                  Paying online is quicker, but you can also pay the fee by
                  transferring the amount directly to our bank account. You can
                  also pay a sum greater than the minimum EMI using this method.
                </p>

                <p className="mt-2">
                  Once you have completed the bank transfer, please email{" "}
                  {this.mailTo("help@sv.co")} with payment details for
                  processing. Our bank account details follow:
                </p>

                <pre className="mt-3">
                  {`Account Number: XXXXXX
IFSC: XXXXXX
Bank: XXXXXX
Branch: XXXXXX`}
                </pre>
              </div>
            </div>

            {!this.props.disabled && (
              <div className="col-lg-5">
                <div className="row">
                  <div className="col-12">
                    <BillingAddressForm
                      rootState={this.state}
                      setRootState={this.setRootState}
                      states={this.props.states}
                    />
                  </div>
                </div>

                <div className="row mt-3">
                  <div className="col-12">
                    <FeeOffer
                      rootState={this.state}
                      setRootState={this.setRootState}
                    />
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }
}

Interface.propTypes = {
  debug: PropTypes.bool.isRequired,
  disabled: PropTypes.bool.isRequired,
  paymentRequested: PropTypes.bool.isRequired,
  coupon: PropTypes.shape({
    code: PropTypes.string,
    discount: PropTypes.number,
    instructions: PropTypes.string
  }),
  fee: PropTypes.shape({
    originalFee: PropTypes.number,
    discountedFee: PropTypes.number,
    payableFee: PropTypes.number,
    emi: PropTypes.number
  }),
  startup: PropTypes.shape({
    billingAddress: PropTypes.string,
    billingStateId: PropTypes.number
  }),
  states: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string
    })
  )
};
