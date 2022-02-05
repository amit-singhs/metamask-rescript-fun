open Promise
type ethersModule
type utils
type utilsModule
type address
type addParams = {method: string, params: array<string>}
type ethers = {utils: utilsModule}
type requestParams = {method: string}
type ethereum = {
  isMetaMask: bool,
  request: requestParams,
}
type state = {accountAddress: option<string>}
type handlers = {
  connectToMetamaskWallet: ReactEvent.Mouse.t => unit,
  // onListener: ReactEvent.Mouse.t => unit,
}
type window = {ethereum: ethereum}
@val external window: window = "window"
%%raw("import {ethers} from 'ethers'")
@val external ethers: ethers = "ethers"
@send external sendRequest: (ethereum, requestParams) => Promise.t<array<string>> = "request"
@send external sendBalanceRequest: (ethereum, addParams) => Promise.t<string> = "request"
@send external formatEther: (utilsModule, string) => string = "formatEther"
@send external onAccountChangeListener: (ethereum, string => unit) => unit = "on"

@react.component
let make = () => {
  let (metamaskAddress, setMetamaskAddress) = React.useState(_ => None)
  let (accountBalance, setAccountBalance) = React.useState(_ => None)

  let handlers = {
    connectToMetamaskWallet: _ => {
      let _ =
        window.ethereum
        ->sendRequest({method: "eth_requestAccounts"})
        ->then(acc => {
          Js.log2("Acc value fetched after promise: ", acc)
          setMetamaskAddress(_ => Some(acc[0]))
          let _ =
            window.ethereum
            ->sendBalanceRequest({
              method: "eth_getBalance",
              params: [acc[0], "latest"],
            })
            ->then(someBal => {
              Js.log2("Somebalance fetched is: ", someBal)
              let bal = ethers.utils->formatEther(someBal)
              // setAccountBalance(_ => Some(someBal))
              setAccountBalance(_ => Some(bal))
              Js.log2("Ultimate value of bal fetched is: ", bal)
              resolve()
            })
            ->ignore
          resolve()
        })
        ->ignore
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
      <p>
        {"Account address: "->React.string}
        {metamaskAddress
        ->Belt.Option.getWithDefault("value unavailable(Metamsk not connected)")
        ->React.string}
      </p>
      <p>
        {"Account balance: "->React.string}
        {accountBalance
        ->Belt.Option.getWithDefault("value unavailable(Metamask not connected)")
        ->React.string}
      </p>
    </div>
  </div>
}
// method for sending balance request :
//window.ethereum.request({method:"eth_getBalance", params:["0xd3b04b0467e627def9008d2bcc8a0b517a2cbcf2", "latest"]})
