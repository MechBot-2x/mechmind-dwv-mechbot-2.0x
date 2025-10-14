use openssl::ssl::{SslMethod, SslConnector};

#[no_mangle]
pub extern "C" fn init_crypto_engine() -> bool {
    let builder = SslConnector::builder(SslMethod::tls()).unwrap();
    let _connector = builder.build();
    true
}
