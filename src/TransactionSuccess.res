@react.component
let make = (~txResponse: option<Metamask.transactionResponse>) => {
  let classes = "mt-5 border border-green-500 bg-green-200 rounded-md p-5"

  switch txResponse {
  | None => <p className={classes}> {"Transaction Failed "->React.string} </p>
  | Some(response) =>
    <div className={classes}>
      <p> {"Transaction successful"->React.string} </p>
      <p> {"Transaction ID: "->React.string} {response.hash->React.string} </p>
    </div>
  }
}
