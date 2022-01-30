type requestParams = {method: string}
type ethereum = {
  isMetaMask: bool,
  request: requestParams,
}
type window = {ethereum: ethereum}
@val external window: window = "window"
@send external sendRequest: (ethereum, requestParams) => string = "request"
let win = window.ethereum
// Js.log2("metamask value fetched is: ", win)
Js.log2(
  "Connected to metamsk wallet: ",
  window.ethereum->sendRequest({method: "eth_requestAccounts"}),
)
@react.component
let make = () => {
  <div>
    <p className="p-5 text-3xl"> {React.string("Welcome to Metamask test")} </p>
    <p className="p-5 text-3xl"> {React.string("Hello")} </p>
  </div>
}
