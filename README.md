# Hyprland IPC

An elixir application to handle Hyprland events via ~IPC~ hyprctl.

This application is tailor made to my needs to dispatch request to Hyprland
based on specific events, such as:

- A firefox window changed its title that now start with "FW"
- Bitwarden firefox extension opens

and so on

## Motivation

- An easy application to bundle via nix and to make a nix shell for
- Got sick of the imperative way to match specific pattern (give me those fancy pattern matches on function heads)

## Usage

```
nix build .#hyprland-ipc
nix run .#hyprland-ipc start_iex
```

The application then automatically connects to Hyprland's events socket and
waits for events.
