open Promise
type ethersModule
type utils
type address
type addParams = {method: string, params: array<array<string>>}
type ethers = {utils: string}
type requestParams = {method: string}
type ethereum = {
  isMetaMask: bool,
  request: requestParams,
}
type state = {accountAddress: option<string>}
type handlers = {connectToMetamaskWallet: ReactEvent.Mouse.t => unit}
type window = {ethereum: ethereum}
@val external window: window = "window"
@send external sendRequest: (ethereum, requestParams) => Promise.t<string> = "request"
@send external sendBalanceRequest: (ethereum, addParams) => Promise.t<string> = "request"
@send external formatEther: (utils, string) => Promise.t<'a> = "formatEther"
%%raw("import {ethers} from 'ethers';")
// let some = ethers.utils->formatEther("acc1")
// Js.log2("some value is: ", some)
// Js.log2("metamask value fetched is: ", win)
/* Js.log2(
  "Connected to metamsk wallet: ",
  window.ethereum->sendRequest({method: "eth_requestAccounts"}),
) */

@react.component
let make = () => {
  let (metamaskAddress, setMetamaskAddress) = React.useState(_ => [""])
  let (accountBalance, setAccountBalance) = React.useState(_ => None)
  let handlers = {
    connectToMetamaskWallet: _ => {
      let _ =
        window.ethereum
        ->sendRequest({method: "eth_requestAccounts"})
        ->then(acc => {
          Js.log2("Acc value fetched after promise: ", acc)
          setMetamaskAddress(_ => [acc])
          let _ =
            window.ethereum
            ->sendBalanceRequest({
              method: "eth_getBalance",
              params: [[acc], ["latest"]],
            })
            ->then(someBal => {
              Js.log2("Somebalance fetched is: ", someBal)
              resolve()
            })
          resolve({method: "eth_requestAccounts"})
        })
    },
  }
  <div>
    <p className="p-5 text-3xl"> {React.string("Welcome to Metamask test")} </p>
    <div className="p-5">
      <button
        className="p-5 bg-blue-400 rounded-lg text-white"
        onClick={handlers.connectToMetamaskWallet}>
        {"Connect to Metamask"->React.string}
      </button>
    </div>
    <div className="p-5 text-3xl ">
      <p> {"Account address: "->React.string} {metamaskAddress[0]->React.string} </p>
      <p>
        {"Account balance: "->React.string}
        {accountBalance
        ->Belt.Option.getWithDefault("value not available(Metamask not connected)")
        ->React.string}
      </p>
    </div>
  </div>
}
