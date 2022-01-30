switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<div> <MetamaskTest /> </div>, root)
| None => () // do nothing
}
