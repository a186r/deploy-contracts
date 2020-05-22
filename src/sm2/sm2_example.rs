use libsm::sm2::signature::{SigCtx};
use cita_web3::web3::futures::Future;
use cita_web3::web3::types::Bytes;


pub fn deploy_sm2(){
    let ctx = SigCtx::new();

    // generate a key pair
    let (pk, sk) = ctx.new_keypair();

    let msg = [1_u8];

    // sign and verify
    let signature = ctx.sign(&msg, &sk, &pk);
    let result: bool = ctx.verify(&msg, &pk, &signature);
    println!("verify result is: {}", result);

    let (_eloop, transport) = cita_web3::web3::transports::Http::new("http://127.0.0.1:1337").unwrap();
    let web3 = cita_web3::web3::Web3::new(transport);
    let _accounts = web3.eth().accounts();

}

pub fn query_height() {
    let (_eloop, transport) = cita_web3::web3::transports::Http::new("http://127.0.0.1:1337").unwrap();
    let web3 = cita_web3::web3::Web3::new(transport);

    // 获取accounts
    let accounts = web3.eth().accounts().wait().unwrap();
    
    
    // 拼接交易


    let nonce = web3.eth().send_raw_transaction(Bytes::from("hello")).wait().unwrap();
}