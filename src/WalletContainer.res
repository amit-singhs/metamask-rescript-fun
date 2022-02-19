open Promise
%%raw("import {ethers} from 'ethers'")

type handlers = {
  connectToMetamaskWallet: ReactEvent.Mouse.t => unit,
  renderTransactionComponent: bool => React.element,
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

let reducer = (state, action) => {
  switch action {
  | SetAccountAddress(someAddress) => {...state, accountAddress: someAddress}
  | SetAccountBalance(someBalance) => {...state, accountBalance: someBalance}
  | SetTransactionFlag => {...state, enableTransaction: true}
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(
    reducer,
    {accountAddress: None, accountBalance: None, enableTransaction: false},
  )

  React.useEffect(() => {
    Js.log("From inside useEffect code block, line 66: ")
    None
  })

  let setAccount = account => {
    SetAccountAddress(Some(account[0]))->dispatch
    let _ =
      Metamask.getAccountBalanceP(account)
      ->then(fetchedBalanceHex => {
        let readableBalance =
          Metamask.ethersUtilsConstructor->Metamask.formatEther(fetchedBalanceHex)
        SetAccountBalance(Some(readableBalance))->dispatch
        SetTransactionFlag->dispatch
        resolve()
      })
      ->ignore
  }
  Metamask.addOnEventListener("accountsChanged", newAcc => {
    setAccount(newAcc)
  })
  let handlers = {
    connectToMetamaskWallet: _ => {
      let _ = Metamask.connectToMetamaskWalletP()->then(fetchedAccount => {
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
      <p> {"Hello"->React.string} </p>
      {handlers.renderTransactionComponent(state.enableTransaction)}
    </div>
  </div>
}
