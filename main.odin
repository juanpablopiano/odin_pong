package main

import "core:math"
import "core:fmt"
import rl "vendor:raylib"

WINDOW_HEIGHT :: 720
WINDOW_WIDTH :: 1280

BALL_SPEED_START :: 500
BALL_SPEED_MAX :: BALL_SPEED_START * 2
BALL_SPEED_GAIN :: 1.05
MAX_BOUNCE_ANGLE :: 60 * math.PI / 180

Input :: struct {
	move1: f32,
	move2: f32,
}

Paddle :: struct {
	pos: rl.Vector2,
	size: rl.Vector2,
	color : rl.Color,
}

Ball :: struct {
	pos: rl.Vector2,
	radius: f32,
	color: rl.Color,
	speed: rl.Vector2,
}

Game :: struct {
	player1: Paddle,
	player2: Paddle,
	ball: Ball,
	speed: f32,
	score: rl.Vector2,
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Pong")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	game := Game {
		player1 = {
			pos = {32, 32},
			size = {16, 96},
			color = rl.WHITE,
		},
		player2 = {
			pos = {WINDOW_WIDTH - 48, 32},
			size = {16, 96},
			color = rl.WHITE,
		},
		ball = {
			radius = 10,
			color = rl.WHITE,
		},
		speed = 400,
	}

	reset_ball(&game.ball)

	for !rl.WindowShouldClose() {
		dt := min(rl.GetFrameTime(), 0.05)

		input := read_input()

		update(&game, input, dt)

		draw(game)
	}
}

read_input :: proc() -> Input {
	input: Input

	if rl.IsKeyDown(.S) do input.move1 += 1
	if rl.IsKeyDown(.W) do input.move1 -= 1

	if rl.IsKeyDown(.DOWN) do input.move2 += 1
	if rl.IsKeyDown(.UP) do input.move2 -= 1

	input.move1 = clamp(input.move1, -1, 1)
	input.move2 = clamp(input.move2, -1, 1)

	return input
}

update :: proc(g: ^Game, i: Input, dt: f32) {
	p1 := &g.player1
	p2 := &g.player2
	b := &g.ball

	move_player(p1, i.move1, g.speed, dt)
	move_player(p2, i.move2, g.speed, dt)

	b.pos.y += b.speed.y * dt
	b.pos.x += b.speed.x * dt

	if b.pos.y < b.radius || b.pos.y > WINDOW_HEIGHT - b.radius do b.speed.y *= -1
	if b.pos.x >= WINDOW_WIDTH {
		g.score.x += 1
	} else if b.pos.x <= 0 {
		g.score.y += 1
	}
	if b.pos.x > WINDOW_WIDTH || b.pos.x < 0 do reset_ball(b)

	collision1 := rl.CheckCollisionCircleRec(b.pos, b.radius, rl.Rectangle{p1.pos.x, p1.pos.y, p1.size.x, p1.size.y})
	collision2 := rl.CheckCollisionCircleRec(b.pos, b.radius, rl.Rectangle{p2.pos.x, p2.pos.y, p2.size.x, p2.size.y})
	if collision1 || collision2 {
		b.speed.x *= -1.05
	}
}

reset_ball :: proc(b: ^Ball) {
	speed : f32 = 500
	b.pos = {WINDOW_WIDTH * 0.5, WINDOW_HEIGHT * 0.5}
	b.speed = {
		rl.GetRandomValue(0, 1) == 1 ? speed : -speed,
		f32(rl.GetRandomValue(-100, 100)),
	}
}

draw :: proc(g: Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)

	rl.DrawLineDashed({WINDOW_WIDTH * 0.5, 0}, {WINDOW_WIDTH * 0.5, WINDOW_HEIGHT}, 20, 20, rl.WHITE)

	draw_player(g.player1)
	draw_player(g.player2)

	rl.DrawCircleV(g.ball.pos, g.ball.radius, g.ball.color)

	rl.DrawText(fmt.ctprint(g.score.x), WINDOW_WIDTH * 0.25, 50, 120, rl.WHITE)
	rl.DrawText(fmt.ctprint(g.score.y), WINDOW_WIDTH * 0.75, 50, 120, rl.WHITE)

	rl.DrawText(fmt.ctprint(g.ball.speed.x), 50, 50, 40, rl.WHITE)
	rl.DrawText(fmt.ctprint(g.ball.speed.y), 50, 100, 40, rl.WHITE)
}

draw_player :: proc(p: Paddle) {
	rl.DrawRectangleV(p.pos, p.size, p.color)
}

move_player :: proc(p: ^Paddle, mov: f32, speed: f32, dt: f32) {
	if mov != 0 do p.pos.y += speed * dt * mov
	if p.pos.y < 0 do p.pos.y = 0
	if p.pos.y + p.size.y > WINDOW_HEIGHT do p.pos.y = WINDOW_HEIGHT - p.size.y
}
