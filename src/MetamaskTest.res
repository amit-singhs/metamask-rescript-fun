open Promise
type ethersModule
type utils
type utilsModule
type address
type location
type addParams = {method: string, params: array<string>}
type ethers = {utils: utilsModule}
type requestParams = {method: string}
type ethereum = {
  isMetaMask: bool,
  request: requestParams,
}
type handlers = {connectToMetamaskWallet: ReactEvent.Mouse.t => unit}
type action =
  | SetAccountAddress(option<string>)
  | SetAccountBalance(option<string>)
type state = {
  accountAddress: option<string>,
  accountBalance: option<string>,
}

type window = {ethereum: ethereum}
%%raw("import {ethers} from 'ethers'")

@scope("window") @val external ethereumConstructor: ethereum = "ethereum"
@scope("window") @val external locationConstructor: location = "location"
@send external reload: location => unit = "reload"
@scope("ethers") @val external ethersConstructor: ethers = "utils"
@scope("window.ethereum") @val
external addOnEventListener: (string, array<string> => unit) => unit = "on"
@scope("window.ethereum") @val
external addChainChangeListener: (string, unit => unit) => unit = "on"
@send external sendRequest: (ethereum, requestParams) => Promise.t<array<string>> = "request"
@send external sendBalanceRequest: (ethereum, addParams) => Promise.t<string> = "request"
@send external formatEther: (ethers, string) => string = "formatEther"
@send external onAccountChangeListener: (ethereum, string, unit => unit) => unit = "on"

let reducer = (state, action) => {
  switch action {
  | SetAccountAddress(someAddress) => {...state, accountAddress: someAddress}
  | SetAccountBalance(someBalance) => {...state, accountBalance: someBalance}
  }
}

@react.component
let make = () => {
  let (windowEthereumObject, _setWindowEthereumObject) = React.useState(_ => ethereumConstructor)
  let (ethersUtilObject, _setEthersUtilObject) = React.useState(_ => ethersConstructor)
  let (state, dispatch) = React.useReducer(reducer, {accountAddress: None, accountBalance: None})

  React.useEffect(() => {
    Js.log("From inside useEffect code block, line 66: ")

    None
  })

  addChainChangeListener("chainChanged", _ => {
    locationConstructor->reload
  })

  let setAccount = account => {
    SetAccountAddress(Some(account[0]))->dispatch
    let _ =
      windowEthereumObject
      ->sendBalanceRequest({
        method: "eth_getBalance",
        params: [account[0], "latest"],
      })
      ->then(fetchedBalanceHex => {
        let readableBalance = ethersUtilObject->formatEther(fetchedBalanceHex)
        SetAccountBalance(Some(readableBalance))->dispatch
        resolve()
      })
  }
  Js.log2("windowObj use state value: ", windowEthereumObject)
  windowEthereumObject
  ->sendRequest({method: "eth_requestAccounts"})
  ->then(acc => {
    Js.log2("Acc value fetched is: ", acc)
    addOnEventListener("accountsChanged", newAcc => {
      setAccount(newAcc)
      Js.log2("Accounts changed notification from line 91. New acc is: ", newAcc)
    })
    resolve()
  })
  ->ignore

  let handlers = {
    connectToMetamaskWallet: _ => {
      let _ =
        windowEthereumObject
        ->sendRequest({method: "eth_requestAccounts"})
        ->then(fetchedAccount => {
          setAccount(fetchedAccount)
          resolve()
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
