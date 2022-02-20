open Promise
type action =
  | SetToAddress(option<string>)
  | SetAmount(option<string>)
  | SetAmountFlag(bool)
  | SetToAddressFlag(bool)

type state = {
  toAddress: option<string>,
  amount: option<string>,
  toAddressFlag: bool,
  amountFlag: bool,
}

type handlers = {
  updateToAddress: ReactEvent.Form.t => unit,
  updateAmount: ReactEvent.Form.t => unit,
  handleSubmit: ReactEvent.Mouse.t => unit,
}

let reducer = (state, action) => {
  switch action {
  | SetToAddress(someToAddress) => {...state, toAddress: someToAddress}
  | SetAmount(someAmount) => {...state, amount: someAmount}
  | SetAmountFlag(flag) => {...state, amountFlag: flag}
  | SetToAddressFlag(flag) => {...state, toAddressFlag: flag}
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(
    reducer,
    {toAddress: None, amount: None, toAddressFlag: false, amountFlag: false},
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
      Metamask.submitTransactionP(
        state.amount->Belt.Option.getWithDefault(""),
        state.toAddress->Belt.Option.getWithDefault(""),
      )
      ->then(txId =>
        {
          Js.log2("From handle submit, txid received is: ", txId)
        }->resolve
      )
      ->ignore
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
    </div>
  </div>
}
