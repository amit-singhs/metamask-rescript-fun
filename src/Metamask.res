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
@send external getSigner: provider => signer = "getSigner"
@send external sendTransaction: (signer, transaction) => Promise.t<string> = "sendTransaction"
@new external getWeb3Provider: ethereum => provider = "ethers.providers.Web3Provider"
@send external parseEther: (ethers, string) => string = "parseEther"

// getAccountBalanceP returns a promise with balance information
let getAccountBalanceP = account => {
  ethereumConstructor->sendBalanceRequest({
    method: "eth_getBalance",
    params: [account[0], "latest"],
  })
}
/* connectToMetamaskWallet connects to a metamask wallet and returns a Promise
 with array, with information of account's public address, you would need to confirm
 from your browser's metamask extension */
let connectToMetamaskWalletP = _ => {
  ethereumConstructor->sendRequest({method: "eth_requestAccounts"})
}

/* submitTransaction takes an amount in ethereum and address to which you want to send
that ethereum, and it will submit that transaction to metamask wallet, further on you
would need to confirm this transaction from your metamask wallet */
let submitTransactionP = (amountInEth, toAddress) => {
  let provider = ethereumConstructor->getWeb3Provider
  let signer = provider->getSigner
  let _ = signer->sendTransaction({
    to: toAddress,
    value: ethersUtilsConstructor->parseEther(amountInEth),
  })
}
