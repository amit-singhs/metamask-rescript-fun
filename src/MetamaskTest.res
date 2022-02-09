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
type handlers = {
  connectToMetamaskWallet: ReactEvent.Mouse.t => unit,
  onListener: ReactEvent.Mouse.t => unit,
}
type action =
  | SetAccountAddress(option<string>)
  | SetAccountBalance(option<string>)
type state = {
  accountAddress: option<string>,
  accountBalance: option<string>,
}

type window = {ethereum: ethereum}
// @val external window: window = "window"
// %%raw("import {ethers} from 'ethers'")

// %raw("window.ethereum.on('accountsChanged', accountChangedHandler)")
@val external ethers: ethers = "ethers"
@scope("window") @val external ethereumConstructor: ethereum = "ethereum"
@scope("window.ethereum") @val external addOnEventListener: (string, unit => unit) => unit = "on"
@send external sendRequest: (ethereum, requestParams) => Promise.t<array<string>> = "request"
@send external sendBalanceRequest: (ethereum, addParams) => Promise.t<string> = "request"
@send external formatEther: (utilsModule, string) => string = "formatEther"
@send external onAccountChangeListener: (ethereum, string, unit => unit) => unit = "on"

let reducer = (state, action) => {
  switch action {
  | SetAccountAddress(someAddress) => {...state, accountAddress: someAddress}
  | SetAccountBalance(someBalance) => {...state, accountBalance: someBalance}
  }
}
// let accountChangedHandler = newAcc => {
//   Js.log2("Account changed----------->", newAcc[0])
// }
@react.component
let make = () => {
  let (windowObj, setWindowObj) = React.useState(_ => ethereumConstructor)
  let (state, dispatch) = React.useReducer(reducer, {accountAddress: None, accountBalance: None})

  React.useEffect1(() => {
    let getEthereumObject = () => setWindowObj(_ => ethereumConstructor)
    addOnEventListener("accountsChanged", getEthereumObject)

    // Js.log2("eth object from line 56: ", eth)
    None
  }, [windowObj])

  Js.log2("windowObj use state value: ", windowObj)
  windowObj
  ->sendRequest({method: "eth_requestAccounts"})
  ->then(acc => {
    Js.log2("Acc value fetched is: ", acc)
    resolve()
  })
  ->ignore
  let handlers = {
    connectToMetamaskWallet: _ => {
      // let _ =
      //   window.ethereum
      //   ->sendRequest({method: "eth_requestAccounts"})
      //   ->then(acc => {
      //     Js.log2("Acc value fetched after promise: ", acc)
      //     SetAccountAddress(Some(acc[0]))->dispatch
      //     let _ =
      //       window.ethereum
      //       ->sendBalanceRequest({
      //         method: "eth_getBalance",
      //         params: [acc[0], "latest"],
      //       })
      //       ->then(someBal => {
      //         Js.log2("Somebalance fetched is: ", someBal)
      //         let bal = ethers.utils->formatEther(someBal)
      //         // setAccountBalance(_ => Some(someBal))
      //         SetAccountBalance(Some(bal))->dispatch
      //         Js.log2("Ultimate value of bal fetched is: ", bal)
      //         resolve()
      //       })
      //       ->ignore
      //     resolve()
      //   })
      //   ->ignore
      Js.log("Empty function")
    },
    onListener: _ => {
      // window.ethereum->onAccountChangeListener("accountsChanged", newAccount => {
      //   Js.log2("Account were changed in metamask--->", newAccount)
      // })
      Js.log("Empty onlistener")
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
        {state.accountAddress
        ->Belt.Option.getWithDefault("value unavailable(Metamask not connected)")
        ->React.string}
      </p>
      <p>
        {"Account balance: "->React.string}
        {state.accountBalance
        ->Belt.Option.getWithDefault("value unavailable(Metamask not connected)")
        ->React.string}
      </p>
    </div>
  </div>
}
