package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

@(private = "file")
MAX_I64_STRING_LENGTH :: 19 // fmt.println(len(fmt.tprintf("%i", max(i64))))

@(private = "file")
parse_range :: proc(
	range_str: string,
	allocator := context.temp_allocator,
) -> (
	low, high: int,
	ok: bool,
) {
	parts, split_err := strings.split(range_str, "-", allocator)
	assert(split_err == nil)
	if len(parts) != 2 do return 0, 0, false

	low_val, low_val_ok := strconv.parse_int(strings.trim_space(parts[0]), 10)
	high_val, high_val_ok := strconv.parse_int(strings.trim_space(parts[1]), 10)

	if !low_val_ok || !high_val_ok || high_val < low_val || low_val < 0 do return 0, 0, false

	return low_val, high_val, true
}

@(private = "file")
is_id_invalid :: proc(id_str: string) -> bool {
	if len(id_str) < 2 do return false

	for pattern_len in 1 ..= len(id_str) / 2 {
		if len(id_str) % pattern_len != 0 do continue

		pattern := id_str[:pattern_len]
		is_match := true

		for i := pattern_len; i < len(id_str); i += pattern_len {
			if id_str[i:i + pattern_len] != pattern {
				is_match = false
			}
		}

		if is_match do return true
	}

	return false
}

main :: proc() {
	puzzle_input, read_ok := os.read_entire_file_from_filename("input.txt", context.allocator)
	assert(read_ok)
	defer delete(puzzle_input)

	ranges, split_err := strings.split(string(puzzle_input), ",", context.allocator)
	assert(split_err == nil)
	defer delete(ranges)

	result := 0

	for range in ranges {
		low_val, high_val, parse_ok := parse_range(range, context.temp_allocator)
		assert(parse_ok)

		for id in low_val ..= high_val {
			buf: [MAX_I64_STRING_LENGTH]byte
			id_str := strconv.write_int(buf[:], i64(id), 10)

			if is_id_invalid(id_str) do result += id
		}

		free_all(context.temp_allocator)
	}

	fmt.printfln("Solution 2: %i", result)
}
