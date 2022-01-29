switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<div> <Test /> </div>, root)
| None => () // do nothing
}
