/// Pure logic: easy to unit test, no Godot dependency.
pub fn ping(input: &str) -> String {
    format!("{input} -> pong")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ping_formats() {
        assert_eq!(ping("hi"), "hi -> pong");
    }
}
