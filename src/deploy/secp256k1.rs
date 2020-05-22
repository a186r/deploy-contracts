use std::time;
use web3::contract::{Contract, Options};
use web3::futures::Future;

/// 部署合约到secp256k1算法的链上
pub fn deploy_secp256k1() {
    let (_eloop, transport) = web3::transports::Http::new("http://127.0.0.1:1337").unwrap();
    let web3 = web3::Web3::new(transport);
    let accounts = web3.eth().accounts().wait().unwrap();

    // get current balance
    let balance = web3.eth().balance(accounts[0], None).wait().unwrap();
    println!("current balance: {}", balance);

    // get the contract bytecode for instance from solidity compiler
    let bytecode = include_str!("../../contract-build/StorageFactory.bin");
    // deploying a contract
    let contract = Contract::deploy(web3.eth(), include_bytes!("../../contract-build/StorageFactory.abi"))
        .unwrap()
        .confirmations(0)
        .poll_interval(time::Duration::from_secs(10))
        .options(Options::with(|opt| opt.gas = Some(3_000_000.into())))
        .execute(bytecode, (), accounts[0])
        .unwrap()
        .wait()
        .unwrap();

    println!("contract address is: {:?}", contract.address());
}
