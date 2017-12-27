import React from "react";
import PropTypes from "prop-types";

export default class FeeOffer extends React.Component {
  render() {
    return (
      <div className="col-sm-4 content-box text-xs-center fee-offer__box">
        <h5 className="font-semibold text-uppercase fee-offer_period p-b-1 m-b-2">
          1 month
        </h5>
        <div className="m-y-2">
          <div className="fee-offer__amount-highlight">
            <h2 className="font-semibold m-b-0">
              <span className="font-regular">₹</span>8000{" "}
            </h2>
            <p>for 2 founders</p>
            <div className="fee-offer__discount-details">
              <h6 className="fee-offer__discount-title">FULL PRICE</h6>
            </div>
          </div>
        </div>
        <form
          className="js-founder-fee__form"
          action="/founder/fee"
          acceptCharset="UTF-8"
          data-remote="true"
          method="post"
        >
          <div className="p-x-1">
            <div className="js-founder-fee__pay-button">
              <button
                name="button"
                type="submit"
                className="btn btn-md text-uppercase btn-with-icon btn-ghost-primary"
              >
                Pay for 1 month
              </button>
            </div>
          </div>
        </form>
        <div className="js-founder-fee__disabled-pay-button hidden-xs-up">
          <button className="btn btn-md text-uppercase btn-with-icon btn-disabled">
            <i className="fa fa-spinner fa-pulse" />Please wait...
          </button>
        </div>
        <div className="fee-offer__error brand-danger m-t-1 hidden-xs-up">
          <i className="fa fa-warning" />
          <div className="font-semibold">Something went wrong! </div>Please
          refresh the page and try again
        </div>
      </div>
    );
  }
}

FeeOffer.propTypes = {
  period: PropTypes.number.isRequired,
  recommended: PropTypes.bool.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
