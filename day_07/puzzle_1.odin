package main

import "core:fmt"
import "core:os/os2"

get_index_at :: proc(row, col, num_cols: int) -> int {
	return row * num_cols + col
}

main :: proc() {
	puzzle_input, read_err := os2.read_entire_file("input.txt", context.allocator)
	assert(read_err == nil)
	defer delete(puzzle_input)

	input_str := string(puzzle_input)
	result := 0

	beams := make(map[int]bool)
	defer delete(beams)

	num_cols := -1
	start_pos := -1

	for i := 0; i < len(input_str); i += 1 {
		curr_char := input_str[i]

		if num_cols == -1 && curr_char == '\n' {
			num_cols = i + 1
		}

		if start_pos == -1 && curr_char == 'S' {
			start_pos = i
		} else if start_pos != -1 && curr_char == 'S' {
			panic("Only one starting point is permitted")
		}

		if num_cols == -1 || start_pos == -1 do continue

		row := i / num_cols
		col := i % num_cols
		above_i := get_index_at(row - 1, col, num_cols)

		if curr_char == '.' {
			if input_str[above_i] == 'S' || above_i in beams do beams[i] = true
		} else if curr_char == '^' {
			left_i := get_index_at(row, col - 1, num_cols)
			right_i := get_index_at(row, col + 1, num_cols)

			if right_i >= len(input_str) do continue
			if above_i in beams {
				split := false
				if input_str[left_i] == '.' {
					beams[left_i] = true
					split = true
				}
				if input_str[right_i] == '.' {
					beams[right_i] = true
					split = true
				}
				if split do result += 1
			}
		}
	}

	if num_cols == -1 do panic("Could not determine the grid size")
	if start_pos == -1 do panic("No starting point found")

	fmt.printfln("Solution 1: %v", result)
}
