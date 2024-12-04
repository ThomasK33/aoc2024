const std = @import("std");

pub const name: []const u8 = "day3";

const max_number_length = 3;

pub fn run(
    allocator: std.mem.Allocator,
    args: [][]u8,
) !void {
    if (args.len < 1) {
        return error.MissingFileName;
    }

    // read file contents up to 32KB
    const contents = try std.fs.cwd().readFileAlloc(allocator, args[0], 32 * 1024);
    defer allocator.free(contents);

    var current_state = State.None;

    var first_number: [max_number_length]?u8 = undefined;
    var first_index: u2 = 0;
    var second_number: [max_number_length]?u8 = undefined;
    var second_index: u2 = 0;

    var result: u64 = 0;
    var mul_enabled: bool = true;

    const do_instruction = "do()";
    const dont_instruction = "don't()";
    const mul_instruction = "mul(";

    var i: usize = 0;
    while (i < contents.len) : (i += 1) {
        const value = contents[i];

        if (value == 'd') {
            if (contents.len > i + do_instruction.len and
                std.mem.eql(u8, contents[i .. i + do_instruction.len], do_instruction))
            {
                mul_enabled = true;
                i += do_instruction.len - 1;
                continue;
            } else if (contents.len > i + dont_instruction.len and
                std.mem.eql(u8, contents[i .. i + dont_instruction.len], dont_instruction))
            {
                mul_enabled = false;
                i += dont_instruction.len - 1;
                continue;
            }
        } else if (value == 'm' and
            contents.len > i + mul_instruction.len and
            std.mem.eql(u8, contents[i .. i + mul_instruction.len], mul_instruction))
        {
            current_state = State.Mul;
            // We're going to be adding the numbers in reverse into the array.
            // This will enable use to later on iterate over the array and
            // add the digit times power of 10 to the currently existing one.
            first_index = max_number_length;
            second_index = max_number_length;
            first_number = .{null} ** max_number_length;
            second_number = .{null} ** max_number_length;

            i += mul_instruction.len - 1;

            continue;
        } else if (current_state == State.Mul and std.ascii.isDigit(value)) {
            if (0 < first_index) {
                first_index -= 1;
                first_number[first_index] = value - '0';
                continue;
            }
        } else if (current_state == State.Mul and value == ',') {
            current_state = State.Comma;
            continue;
        } else if (current_state == State.Comma and std.ascii.isDigit(value)) {
            if (0 < second_index) {
                second_index -= 1;
                second_number[second_index] = value - '0';
                continue;
            }
        } else if (current_state == State.Comma and value == ')') {
            if (mul_enabled) {
                var first_int: u32 = 0;
                var first_pow: u2 = 0;
                for (first_number) |digit| {
                    if (digit) |v| {
                        first_int += v * std.math.pow(u32, 10, first_pow);
                        first_pow += 1;
                    }
                }
                var second_int: u32 = 0;
                var second_pow: u2 = 0;
                for (second_number) |digit| {
                    if (digit) |v| {
                        second_int += v * std.math.pow(u32, 10, second_pow);
                        second_pow += 1;
                    }
                }

                result += first_int * second_int;
            }
        }

        current_state = State.None;
        first_index = max_number_length;
        second_index = max_number_length;
        first_number = .{null} ** max_number_length;
        second_number = .{null} ** max_number_length;
    }

    std.debug.print("result: {}\n", .{result});
}

const State = enum {
    None,
    Mul,
    Comma,
};
