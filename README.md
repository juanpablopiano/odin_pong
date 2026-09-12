# Pong

A two-player Pong clone written in [Odin](https://odin-lang.org/) with
[raylib](https://www.raylib.com/) (`vendor:raylib`). The whole game fits in a
single file: `main.odin`.

## Requirements

- The Odin compiler (raylib ships with the `vendor` library)

## Build and play

```sh
odin run .
```

Or build the executable into `build/`:

```sh
mkdir -p build
odin build . -out:build/pong
```

## Controls

| Action      | Player 1 | Player 2 |
| ----------- | -------- | -------- |
| Move up     | `W`      | `↑`      |
| Move down   | `S`      | `↓`      |

`Esc` quits the game.

## How it works

A 1280x720 window running at 60 FPS. The ball bounces off the top and bottom
walls and reverses direction when it hits a paddle. When it leaves through a
side, the opposing player scores a point and the ball returns to the center with
a random direction. The score is drawn on either side of the dashed center line.

The main loop follows the classic *input → update → draw* pattern, split into
small procedures (`read_input`, `update`, `draw`) operating on a single `Game`
struct.

## Ideas / TODO

- Bounce angle based on where the ball hits the paddle
- Ramp up ball speed during a rally
- Sound effects and a start menu
- CPU-controlled opponent
