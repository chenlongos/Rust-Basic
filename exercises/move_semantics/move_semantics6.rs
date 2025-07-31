// move_semantics6.rs
//
// You can't change anything except adding or removing references.
//
// Execute `rustlings hint move_semantics6` or use the `hint` watch subcommand
// for a hint.


fn main() {
    let data = "Rust is great!".to_string();

    //005
    get_char(&data);

    //005
    string_uppercase(data);
}

// Should not take ownership
//005
fn get_char(data: &String) -> char {
    data.chars().last().unwrap()
}

// Should take ownership
//005
fn string_uppercase(mut data: String) {
    data = data.to_uppercase();

    println!("{}", data);
}