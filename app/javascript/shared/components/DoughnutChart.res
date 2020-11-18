%bs.raw(`require("./DoughnutChart.css")`)

let str = React.string

type rec mode =
  | Determinate(current, total)
  | Indeterminate
and current = int
and total = int

type color = Purple

let percentage = (current, total) =>
  int_of_float(float_of_int(current) /. float_of_int(total) *. 100.00)

let progress = mode =>
  switch mode {
  | Determinate(current, total) => percentage(current, total)
  | Indeterminate => 100
  }

let classes = (mode, color, className) =>
  "doughnut-chart " ++
  (switch color {
  | Purple => "purple"
  } ++
  (" " ++
  (className ++
  (" " ++
  switch mode {
  | Determinate(_, _) => ""
  | Indeterminate => "animate-pulse"
  }))))

@react.component
let make = (~mode, ~color=Purple, ~className="", ~hideSymbol=false) =>
  <svg viewBox="0 0 36 36" className={classes(mode, color, className)}>
    <path
      className="doughnut-chart__bg"
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <path
      className="doughnut-chart__stroke"
      strokeDasharray={string_of_int(progress(mode)) ++ ", 100"}
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <text x="50%" y="58%" className="doughnut-chart__text font-semibold">
      {switch mode {
      | Determinate(current, _) => str(string_of_int(current) ++ (hideSymbol ? "" : " %"))
      | Indeterminate => React.null
      }}
    </text>
  </svg>
