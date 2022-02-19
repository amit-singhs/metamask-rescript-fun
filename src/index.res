switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<div> <WalletContainer /> </div>, root)
| None => () // do nothing
}
