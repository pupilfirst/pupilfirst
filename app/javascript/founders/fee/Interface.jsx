import * as React from "react";
import FeeOffer from "./interface/FeeOffer";
import BillingAddressForm from "./interface/BillingAddressForm";
import CouponAdder from "./interface/CouponAdder";
import CouponRemover from "./interface/CouponRemover";

export default class Interface extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      // TODO: Compute this at the beginning
      couponFormState: "visible"
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

  canSubmitCoupon() {
    return true;
  }

  canRemoveCoupon() {
    return false;
  }

  couponCode() {}
  couponBenefit() {}
  couponInstructions() {}

  removeCouponButton() {
    return <div className="btn btn-default">Remove (update this)</div>;
  }

  paymentRequested() {
    return false;
  }

  render() {
    return (
      <div className="container">
        <div className="row m-t-3 m-b-3">
          <div className="col-lg-7">
            <div className="content-box apply-submitted">
              <h3 className="text-xs-center m-b-1">
                <span className="brand-secondary font-semibold">
                  Please pay the membership fee to continue.
                </span>
              </h3>

              <ul className="admissions-fee__important-points m-b-1">
                <li>
                  It covers your team of{" "}
                  <strong>{this.billingFoundersCount()} founders</strong>.
                </li>
                <li>
                  You can change your team at any time. Just reach us on{" "}
                  {this.mailTo("help@sv.co")}.
                </li>
              </ul>

              {this.paymentRequested() && (
                <div className="alert alert-warning m-t-1">
                  <i className="fa fa-warning" /> It looks like you've attempted
                  to pay at least once before, but didn't complete the process.
                  Note that it might take a few minutes for the payment status
                  to update, if you experienced network issues after completing
                  the payment. Please contact us at {this.mailTo("help@sv.co")}{" "}
                  if you're experiencing any issue.
                </div>
              )}

              {(this.canSubmitCoupon() || this.canRemoveCoupon) && (
                <div className="row">
                  <div className="offset-md-2 col-md-8">
                    <div className="coupon-form-container text-xs-center m-x-auto">
                      {this.canRemoveCoupon() && (
                        <CouponRemover
                          rootState={this.state}
                          setRootState={this.setRootState}
                        />
                      )}
                      {this.canSubmitCoupon() && (
                        <CouponAdder
                          rootState={this.state}
                          setRootState={this.setRootState}
                        />
                      )}
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          <div className="col-lg-5">
            <BillingAddressForm
              rootState={this.state}
              setRootState={this.setRootState}
            />
          </div>
        </div>

        <div className="fee-offer__container m-b-3">
          <FeeOffer
            key={1}
            period={1}
            recommended={false}
            rootState={this.state}
            setRootState={this.setRootState}
          />
          <FeeOffer
            key={6}
            period={6}
            recommended={true}
            rootState={this.state}
            setRootState={this.setRootState}
          />
          <FeeOffer
            key={3}
            period={3}
            recommended={false}
            rootState={this.state}
            setRootState={this.setRootState}
          />
        </div>
      </div>
    );
  }
}

// FeeInterface.propTypes = {
//   debug: PropTypes.bool
// };
