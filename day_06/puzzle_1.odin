package main

import "core:fmt"
import "core:os/os2"
import "core:strconv"
import "core:strings"

@(private = "file")
TOKEN_ASTERISK :: "*"
@(private = "file")
TOKEN_PLUS :: "+"

main :: proc() {
	puzzle_input, read_err := os2.read_entire_file("input.txt", context.allocator)
	assert(read_err == nil)
	defer delete(puzzle_input)

	result := 0

	stacks := make([dynamic][dynamic]int)
	defer {
		for stack in stacks {
			delete(stack)
		}
		delete(stacks)
	}

	input_str := string(puzzle_input)
	for line in strings.split_lines_iterator(&input_str) {
		defer free_all(context.temp_allocator)

		tokens, split_err := strings.split(line, " ", context.temp_allocator)
		assert(split_err == nil)

		if len(tokens) < 1 do continue

		i := 0
		for token in tokens {
			if len(token) == 0 do continue
			if len(stacks) < i + 1 {
				stack := make([dynamic]int)
				inject_at(&stacks, i, stack)
			}

			val, is_int := strconv.parse_int(token, 10)
			if is_int do append(&stacks[i], val)
			else {
				sum := stacks[i][0]

				for x := 1; x < len(stacks[i]); x += 1 {
					switch token {
					case TOKEN_ASTERISK:
						sum *= stacks[i][x]
					case TOKEN_PLUS:
						sum += stacks[i][x]
					case:
						panic("Unknown token")
					}
				}

				clear(&stacks[i])
				result += sum
			}

			i += 1
		}
	}

	fmt.printfln("Solution 1: %v", result)
}
