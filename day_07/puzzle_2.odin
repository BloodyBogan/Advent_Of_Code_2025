package main

import "core:fmt"
import "core:os/os2"
import "core:strings"

Vector2 :: [2]int

DOWN :: Vector2{0, 1}
LEFT :: Vector2{1, 0}
RIGHT :: Vector2{-1, 0}

pop_safe :: proc(stack: ^[dynamic]Vector2) -> (Vector2, bool) {
	if len(stack) == 0 do return {}, false
	val := stack[len(stack) - 1]
	ordered_remove(stack, len(stack) - 1)
	return val, true
}

main :: proc() {
	puzzle_input, read_err := os2.read_entire_file("input.txt", context.allocator)
	assert(read_err == nil)
	defer delete(puzzle_input)

	input_str := string(puzzle_input)
	result := 0

	grid := make([dynamic][dynamic]u8)
	defer {
		for row in grid {
			delete(row)
		}
		delete(grid)
	}

	row_idx := 0
	starting_pos := Vector2{-1, -1}
	for line in strings.split_lines_iterator(&input_str) {
		row := make([dynamic]u8)
		for char, col_idx in line {
			if starting_pos == {-1, -1} && char == 'S' {
				starting_pos = {col_idx, row_idx}
			} else if starting_pos != {-1, -1} && char == 'S' {
				panic("Only one starting position is permitted")
			}
			append(&row, u8(char))
		}
		append(&grid, row)
		row_idx += 1
	}

	stack := make([dynamic]Vector2)
	defer delete(stack)

	visited := make(map[Vector2]bool)
	defer delete(visited)

	cache := make(map[Vector2]int)
	defer delete(cache)

	curr_pos := starting_pos
	for {
		below_pos := curr_pos + DOWN

		if below_pos.y >= len(grid) {
			val, ok := pop_safe(&stack)
			result += 1
			if !ok do break
			curr_pos = val
			continue
		}

		if below_pos in cache {
			result += cache[below_pos]
			val, ok := pop_safe(&stack)
			if !ok do break
			curr_pos = val
			continue
		}

		below_char := grid[below_pos.y][below_pos.x]

		if below_char == '.' {
			curr_pos = below_pos
		} else if below_char == '^' {
			selected: Vector2
			left_pos := below_pos + LEFT
			right_pos := below_pos + RIGHT

			if !(left_pos in visited) {
				cache[curr_pos] = result
				selected = left_pos
			} else if !(right_pos in visited) {
				selected = right_pos
			} else {
				cache[curr_pos] = result - cache[curr_pos]
				delete_key(&visited, curr_pos)
				val, ok := pop_safe(&stack)
				if !ok do break
				curr_pos = val
				delete_key(&visited, left_pos)
				delete_key(&visited, right_pos)
				continue
			}

			append(&stack, curr_pos)
			curr_pos = selected
			visited[selected] = true
		}
	}

	fmt.printfln("Solution 2: %v", result)
}
