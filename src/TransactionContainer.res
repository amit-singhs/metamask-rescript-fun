open Promise
type action =
  | SetToAddress(option<string>)
  | SetAmount(option<string>)
  | SetAmountFlag(bool)
  | SetToAddressFlag(bool)
  | SetTransactionFlag(bool)
  | SetTransactionResponse(option<Metamask.transactionResponse>)

type state = {
  toAddress: option<string>,
  amount: option<string>,
  toAddressFlag: bool,
  amountFlag: bool,
  transactionFlag: bool,
  transactionResponseObject: option<Metamask.transactionResponse>,
}

type handlers = {
  updateToAddress: ReactEvent.Form.t => unit,
  updateAmount: ReactEvent.Form.t => unit,
  handleSubmit: ReactEvent.Mouse.t => unit,
  renderTransactionSuccessComponent: bool => React.element,
}

let reducer = (state, action) => {
  switch action {
  | SetToAddress(someToAddress) => {...state, toAddress: someToAddress}
  | SetAmount(someAmount) => {...state, amount: someAmount}
  | SetAmountFlag(flag) => {...state, amountFlag: flag}
  | SetToAddressFlag(flag) => {...state, toAddressFlag: flag}
  | SetTransactionFlag(flag) => {...state, transactionFlag: flag}
  | SetTransactionResponse(someResponse) => {...state, transactionResponseObject: someResponse}
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(
    reducer,
    {
      toAddress: None,
      amount: None,
      toAddressFlag: false,
      amountFlag: false,
      transactionFlag: false,
      transactionResponseObject: None,
    },
  )

  let handlers = {
    updateToAddress: evt => {
      ReactEvent.Form.preventDefault(evt)
      let value = ReactEvent.Form.target(evt)["value"]
      SetToAddressFlag(true)->dispatch
      SetToAddress(Some(value))->dispatch
    },
    updateAmount: evt => {
      ReactEvent.Form.preventDefault(evt)
      let value = ReactEvent.Form.target(evt)["value"]
      SetAmountFlag(true)->dispatch
      SetAmount(Some(value))->dispatch
    },
    handleSubmit: _ => {
      let _ = Js.log2("from inside handle submit, amount is: ", state.amount)
      let _ = Js.log2("from inside handle submit, address is: ", state.toAddress)
      let _ = Js.log2("from inside handle submit, toAddress flag is: ", state.toAddressFlag)
      let _ = Js.log2("from inside handle submit, amount flag is: ", state.amountFlag)
      let _ =
        Metamask.submitTransactionP(
          state.amount->Belt.Option.getWithDefault(""),
          state.toAddress->Belt.Option.getWithDefault(""),
        )
        ->then(txId =>
          {
            Js.log2("From handle submit, txid received is: ", txId)
            SetTransactionFlag(true)->dispatch
            SetTransactionResponse(Some(txId))->dispatch
          }->resolve
        )
        ->catch(err => {
          Js.log2("Error is caught from promise catch block, error object is: ", err)
          resolve()
        })
    },
    renderTransactionSuccessComponent: successFlag => {
      if successFlag {
        <TransactionSuccess txResponse=state.transactionResponseObject />
      } else {
        <div />
      }
    },
  }

  <div>
    <div className="p-4">
      <p className="mb-7"> {"Send ethereum:"->React.string} </p>
      <input
        type_="text"
        value={state.toAddress->Belt.Option.getWithDefault("")}
        onChange={handlers.updateToAddress}
        placeholder="To address.."
        className="p-5 w-7/12 ring-2 ring-blue-400"
      />
      <input
        type_="text"
        onChange={handlers.updateAmount}
        value={state.amount->Belt.Option.getWithDefault("")}
        placeholder="Amount.."
        className="mt-7 p-5 w-7/12 ring-2 ring-blue-400"
      />
      <div className="mt-5">
        <button
          className="p-3 bg-blue-400  text-xl rounded-lg text-white"
          onClick={handlers.handleSubmit}>
          {"Submit"->React.string}
        </button>
      </div>
      {handlers.renderTransactionSuccessComponent(state.transactionFlag)}
    </div>
  </div>
}
