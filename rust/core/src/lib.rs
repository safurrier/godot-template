/// Pure logic: easy to unit test, no Godot dependency.
pub fn ping(input: &str) -> String {
    format!("{input} -> pong")
}

/// Calculate damage with a multiplier (example game logic).
pub fn calculate_damage(base_damage: i32, multiplier: f32) -> i32 {
    ((base_damage as f32) * multiplier).round() as i32
}

/// Greet a player by name.
pub fn greet_player(name: &str) -> String {
    format!("Welcome to the game, {name}!")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ping_formats() {
        assert_eq!(ping("hi"), "hi -> pong");
    }

    #[test]
    fn calculate_damage_works() {
        assert_eq!(calculate_damage(100, 1.5), 150);
        assert_eq!(calculate_damage(50, 2.0), 100);
        assert_eq!(calculate_damage(10, 0.5), 5);
    }

    #[test]
    fn greet_player_formats() {
        assert_eq!(greet_player("Alex"), "Welcome to the game, Alex!");
    }
}
