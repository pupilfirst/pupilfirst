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
    return true;
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
        <div className="row mt-3 mb-3">
          <div className="col-lg-7">
            <div className="content-box mt-3 mb-3 apply-submitted">
              <h3 className="text-center mb-2">
                You cannot make payments{" "}
                <span className="brand-secondary font-semibold">
                  at this time.
                </span>
              </h3>
              <ul className="admissions-fee__important-points">
                <li>
                  If you need any help please contact us on Slack or mail us at{" "}
                  <a href="mailto:help@sv.co">help@sv.co</a>.
                </li>
              </ul>

              <h3 className="text-center mb-2">
                <span className="brand-secondary font-semibold">
                  Please pay the membership fee to continue.
                </span>
              </h3>
              <ul className="admissions-fee__important-points">
                <li>
                  It covers your team of{" "}
                  <strong>{this.billingFoundersCount()} founders</strong>.
                </li>
                <li>
                  You can change your team at any time. Just reach us on{" "}
                  {this.mailTo("help@sv.co")}.
                </li>
              </ul>

              <ul className="admissions-fee__important-points">
                <li>
                  If you need any help please contact us on Slack or mail us at{" "}
                  <a href="mailto:help@sv.co">help@sv.co</a>.
                </li>
              </ul>

              {this.paymentRequested() && (
                <div className="alert alert-warning mt-2">
                  <i className="fa fa-warning" /> It looks like you've attempted
                  to pay at least once before, but didn&rsquo;t complete the
                  process. Note that it might take a few minutes for the payment
                  status to update, if you experienced network issues after
                  completing the payment. Please contact us at{" "}
                  {this.mailTo("help@sv.co")} if you&rsquo;re experiencing any
                  issue.
                </div>
              )}

              {(this.canSubmitCoupon() || this.canRemoveCoupon) && (
                <div className="row justify-content-center">
                  <div className="col-md-8">
                    <div className="coupon-form-container text-center mx-auto">
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
