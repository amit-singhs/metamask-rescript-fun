open Promise
type ethersModule
type utils
type utilsModule
type providersModule
type provider
type signer
type address
type location
type transaction = {
  to: string,
  value: string,
}
type addParams = {method: string, params: array<string>}
type ethers = {
  utils: utilsModule,
  providers: providersModule,
}
type requestParams = {method: string}
type ethereum = {
  isMetaMask: bool,
  request: requestParams,
}
type handlers = {
  connectToMetamaskWallet: ReactEvent.Mouse.t => unit,
  renderTransactionComponent: bool => React.element,
  submitTransaction: ReactEvent.Mouse.t => unit,
}
type action =
  | SetAccountAddress(option<string>)
  | SetAccountBalance(option<string>)
  | SetTransactionFlag
type state = {
  accountAddress: option<string>,
  accountBalance: option<string>,
  enableTransaction: bool,
}

type window = {ethereum: ethereum}
%%raw("import {ethers} from 'ethers'")

@scope("window") @val external ethereumConstructor: ethereum = "ethereum"
@scope("window") @val external locationConstructor: location = "location"
@send external reload: location => unit = "reload"
@scope("ethers") @val external ethersUtilsConstructor: ethers = "utils"
@scope("ethers") @val external ethersProvidersConstructor: providersModule = "providers"
@scope("window.ethereum") @val
external addOnEventListener: (string, array<string> => unit) => unit = "on"
@scope("window.ethereum") @val
external addChainChangeListener: (string, unit => unit) => unit = "on"
@send external sendRequest: (ethereum, requestParams) => Promise.t<array<string>> = "request"
@send external sendBalanceRequest: (ethereum, addParams) => Promise.t<string> = "request"
@send external formatEther: (ethers, string) => string = "formatEther"
@send external onAccountChangeListener: (ethereum, string, unit => unit) => unit = "on"
@new external getWeb3Provider: providersModule => provider = "Web3Provider"
@send external getSigner: provider => signer = "getSigner"
@send external sendTransaction: (signer, transaction) => Promise.t<string> = "sendTransaction"
@new external getWeb3: ethereum => provider = "ethers.providers.Web3Provider"

let reducer = (state, action) => {
  switch action {
  | SetAccountAddress(someAddress) => {...state, accountAddress: someAddress}
  | SetAccountBalance(someBalance) => {...state, accountBalance: someBalance}
  | SetTransactionFlag => {...state, enableTransaction: true}
  }
}

@react.component
let make = () => {
  let (windowEthereumObject, _setWindowEthereumObject) = React.useState(_ => ethereumConstructor)
  let (ethersUtilObject, _setEthersUtilObject) = React.useState(_ => ethersUtilsConstructor)
  let (ethersProvidersObject, _setEthersProvidersObject) = React.useState(_ =>
    ethersProvidersConstructor
  )
  let (state, dispatch) = React.useReducer(
    reducer,
    {accountAddress: None, accountBalance: None, enableTransaction: false},
  )

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
        SetTransactionFlag->dispatch
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
    renderTransactionComponent: transactionFlag => {
      if transactionFlag {
        <TransactionContainer />
      } else {
        <div />
      }
    },
    submitTransaction: _ => {
      let provider = windowEthereumObject->getWeb3
      let signer = provider->getSigner
      let _ =
        signer
        ->sendTransaction({
          to: "0x9c7e55be1134774ac344481Ee2B8Ea4b7bd2ccfb",
          value: "0x7A120",
        })
        ->then(txId => {
          Js.log2("The transaction id received is: ", txId)
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
      <button
        className="p-3 bg-blue-400  text-xl rounded-lg text-white"
        onClick={handlers.submitTransaction}>
        {"Submit"->React.string}
      </button>
      // {handlers.renderTransactionComponent(state.enableTransaction)}
    </div>
  </div>
}
