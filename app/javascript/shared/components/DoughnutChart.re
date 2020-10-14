[%bs.raw {|require("./DoughnutChart.css")|}];

let str = React.string;

let classes = (pulse, color, className) => {
  "doughnut-chart "
  ++ color
  ++ " "
  ++ className
  ++ " "
  ++ (pulse ? " animate-pulse" : "");
};

[@react.component]
let make =
    (~percentage, ~text=?, ~pulse=false, ~color="purple", ~className="") => {
  <svg viewBox="0 0 36 36" className={classes(pulse, color, className)}>
    <path
      className="doughnut-chart__bg"
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <path
      className="doughnut-chart__stroke"
      strokeDasharray={string_of_int(percentage) ++ ", 100"}
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <text x="50%" y="58%" className="doughnut-chart__text font-semibold">
      {str(
         text->Belt.Option.mapWithDefault(
           string_of_int(percentage) ++ " %", t =>
           t
         ),
       )}
    </text>
  </svg>;
};
