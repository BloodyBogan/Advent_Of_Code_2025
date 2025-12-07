package main

import "core:fmt"
import "core:os/os2"
import "core:strconv"
import "core:strings"
import "core:unicode"

@(private = "file")
TOKEN_ASTERISK :: '*'
@(private = "file")
TOKEN_PLUS :: '+'

main :: proc() {
	puzzle_input, read_err := os2.read_entire_file("input.txt", context.allocator)
	assert(read_err == nil)
	defer delete(puzzle_input)

	result := 0

	stacks := make([dynamic][dynamic]rune)
	defer {
		for stack in stacks {
			delete(stack)
		}
		delete(stacks)
	}

	input_str := string(puzzle_input)
	for line in strings.split_lines_iterator(&input_str) {
		if len(line) < 1 do continue

		i := 0
		for token in line {
			if len(stacks) < i + 1 {
				stack := make([dynamic]rune)
				inject_at(&stacks, i, stack)
			}

			append(&stacks[i], token)

			i += 1
		}
	}

	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	temp_res := 0
	curr_op: rune
	for &stack, l in stacks {
		num_spaces := 0
		for char, i in stack {
			is_space := unicode.is_space(char)

			if !is_space {
				if len(stack) - 1 == i do curr_op = char
				else do strings.write_rune(&builder, char)
			} else do num_spaces += 1
		}

		if num_spaces == len(stack) {
			result += temp_res
			temp_res = 0
		} else {
			val, val_ok := strconv.parse_int(strings.to_string(builder), 10); assert(val_ok)

			if temp_res == 0 do temp_res = val
			else {
				switch curr_op {
				case TOKEN_ASTERISK:
					temp_res *= val
				case TOKEN_PLUS:
					temp_res += val
				case:
					panic("Unknown char")
				}
			}
		}

		clear(&stack)
		strings.builder_reset(&builder)
	}
	result += temp_res

	fmt.printfln("Solution 2: %v", result)
}
