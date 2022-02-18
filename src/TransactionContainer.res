type action =
  | SetToAddress(option<string>)
  | SetAmount(option<float>)

type state = {
  toAddress: option<string>,
  amount: option<float>,
}

type handlers = {
  updateToAddress: ReactEvent.Form.t => unit,
  updateAmount: ReactEvent.Form.t => unit,
}

let reducer = (state, action) => {
  switch action {
  | SetToAddress(someToAddress) => {...state, toAddress: someToAddress}
  | SetAmount(someAmount) => {...state, amount: someAmount}
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, {toAddress: None, amount: None})

  let handlers = {
    updateToAddress: evt => {
      ReactEvent.Form.preventDefault(evt)
      let value = ReactEvent.Form.target(evt)["value"]
      SetToAddress(Some(value))->dispatch
    },
    updateAmount: evt => {
      ReactEvent.Form.preventDefault(evt)
      let value = ReactEvent.Form.target(evt)["value"]
      SetAmount(Some(value))->dispatch
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
        value={state.amount->Belt.Option.getWithDefault(0.0)->Belt.Float.toString}
        placeholder="Amount.."
        className="mt-7 p-5 w-7/12 ring-2 ring-blue-400"
      />
      <div className="mt-5">
        <button className="p-3 bg-blue-400  text-xl rounded-lg text-white">
          {"Submit"->React.string}
        </button>
      </div>
    </div>
  </div>
}