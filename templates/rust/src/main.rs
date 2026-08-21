use std::env;
use std::io::Write;
use std::net::TcpListener;

fn main() {
    let port = env::var("SERVER_PORT").unwrap_or_else(|_| env::var("PORT").unwrap_or_else(|_| "8080".to_string()));
    let addr = format!("0.0.0.0:{}", port);
    let listener = TcpListener::bind(&addr).expect("Could not bind port");
    println!("[PotenFYR] Rust server listening on http://{}", addr);

    for stream in listener.incoming() {
        if let Ok(mut stream) = stream {
            let body = "{\"status\":\"online\",\"message\":\"Hello from PotenFYR Rust Egg!\"}";
            let response = format!(
                "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
                body.len(),
                body
            );
            let _ = stream.write_all(response.as_bytes());
        }
    }
}
