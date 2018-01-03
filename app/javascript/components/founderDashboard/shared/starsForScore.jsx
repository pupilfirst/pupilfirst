import * as React from "react";

export default function starsForScore(score, targetId) {
  let stars = _.times(Math.floor(score)).map(function(e, i) {
    return (
      <i
        key={"filled-star-" + targetId + "-" + i}
        className="fa fa-star founder-dashboard-target-header__status-badge-star"
      />
    );
  });

  if (score % 1 === 0.5) {
    const halfStar = (
      <i
        key={"half-star-" + targetId}
        className="fa fa-star-half-o founder-dashboard-target-header__status-badge-star"
      />
    );
    stars = stars.concat([halfStar]);
  }

  const emptyStars = _.times(3 - Math.ceil(score));

  const emptyStarArray = emptyStars.map(function(e, i) {
    return (
      <i
        key={"empty-star-" + targetId + "-" + i}
        className="fa fa-star-o founder-dashboard-target-header__status-badge-star"
      />
    );
  });

  stars = stars.concat(emptyStarArray);
  return stars;
}
