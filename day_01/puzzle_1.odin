package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

@(private = "file")
Direction :: enum {
	LEFT,
	RIGHT,
}

@(private = "file")
parse_direction :: proc(s: string) -> Maybe(Direction) {
	switch s {
	case "L":
		return .LEFT
	case "R":
		return .RIGHT
	case:
		return nil
	}
}

main :: proc() {
	file_data, read_err := os.read_entire_file_from_filename_or_err("input.txt", context.allocator)
	if read_err != nil {
		fmt.eprintfln("Could not read input file: %s", read_err)
		return
	}
	defer delete(file_data)

	curr_number := 50
	zero_count := 0

	s := string(file_data)
	for line in strings.split_lines_iterator(&s) {
		if len(line) == 0 do continue
		if len(line) < 2 {
			fmt.eprintfln("Invalid line format: %s", line)
			return
		}

		direction := parse_direction(line[:1])
		if direction == nil {
			fmt.eprintfln("Could not parse direction: %s", line[:1])
			return
		}
		num_rotations, ok := strconv.parse_int(line[1:], 10)
		if !ok {
			fmt.eprintfln("Could not parse number of rotations: %s", line[1:])
			return
		}

		movement := -num_rotations if direction == .LEFT else num_rotations

		curr_number = (curr_number + movement) % 100
		if curr_number < 0 do curr_number += 100
		if curr_number == 0 do zero_count += 1
	}

	fmt.printfln("Result: %i", zero_count)
}
