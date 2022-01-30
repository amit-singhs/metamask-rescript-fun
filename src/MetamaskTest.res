type requestParams = {method: string}
type ethereum = {
  isMetaMask: bool,
  request: requestParams,
}
type handlers = {connectToMetamaskWallet: ReactEvent.Mouse.t => unit}
type window = {ethereum: ethereum}
@val external window: window = "window"
@send external sendRequest: (ethereum, requestParams) => string = "request"
let win = window.ethereum
// Js.log2("metamask value fetched is: ", win)
/* Js.log2(
  "Connected to metamsk wallet: ",
  window.ethereum->sendRequest({method: "eth_requestAccounts"}),
) */
let handlers = {
  connectToMetamaskWallet: _ => {
    let eth = window.ethereum->sendRequest({method: "eth_requestAccounts"})
  },
}

@react.component
let make = () => {
  <div>
    <p className="p-5 text-3xl"> {React.string("Welcome to Metamask test")} </p>
    <div className="p-5">
      <button
        className="p-5 bg-blue-400 rounded-lg text-white"
        onClick={handlers.connectToMetamaskWallet}>
        {"Connect to Metamask"->React.string}
      </button>
    </div>
    <p className="p-5 text-3xl "> {React.string("Hello")} </p>
  </div>
}
