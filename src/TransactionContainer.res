type action =
  | SetToAddress(option<string>)
  | SetAmount(option<float>)

type state = {
  toAddress: option<string>,
  amount: option<float>,
}

let reducer = (state, action) => {
  switch action {
  | SetToAddress(_someToAddress) => state
  | SetAmount(_someAmount) => state
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, {toAddress: None, amount: None})

  <div>
    <div className="p-4">
      <p className="mb-7"> {"Send ethereum:"->React.string} </p>
      <input type_="text" placeholder="To address.." className="p-5 w-7/12 ring-2 ring-blue-400" />
      <input type_="text" placeholder="Amount.." className="mt-7 p-5 w-7/12 ring-2 ring-blue-400" />
      <div className="mt-5">
        <button className="p-3 bg-blue-400  text-xl rounded-lg text-white">
          {"Submit"->React.string}
        </button>
      </div>
    </div>
  </div>
}
