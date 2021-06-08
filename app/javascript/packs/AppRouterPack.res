switch ReactDOM.querySelector("#app-router") {
| Some(root) => ReactDOM.render(<AppRouter />, root)
| None => ()
}
