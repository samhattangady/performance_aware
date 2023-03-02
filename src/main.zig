const std = @import("std");

const filepath_part1_1 = "computer_enhance/perfaware/part1/listing_0037_single_register_mov";
const filepath_part1_1_asm = "computer_enhance/perfaware/part1/listing_0037_single_register_mov.asm";
const filepath_part1_2 = "computer_enhance/perfaware/part1/listing_0038_many_register_mov";
const filepath_part1_2_asm = "computer_enhance/perfaware/part1/listing_0038_many_register_mov.asm";

const OPCODE_MASK: u8 = 0b11111100; // page 162
const D_MASK: u8 = 0b00000010;
const W_MASK: u8 = 0b00000001;
const MOD_MASK: u8 = 0b11000000;
const REG_MASK: u8 = 0b00111000;
const R_M_MASK: u8 = 0b00000111;

const MOV_OPCODE: u8 = 0b10001000; // where is this in the manual?

const Mod = enum {
    memory_none,
    memory_8_bit,
    memory_16_bit,
    register_none,

    pub fn parse(val: u8) Mod {
        const shifted = val >> 6;
        return switch (shifted) {
            0b00 => .memory_none,
            0b01 => .memory_8_bit,
            0b10 => .memory_16_bit,
            0b11 => .register_none,
            else => unreachable,
        };
    }
};

const Register = enum {
    AL,
    AX,
    AH,
    BL,
    BX,
    BH,
    CL,
    CX,
    CH,
    DL,
    DX,
    DH,
    SP,
    BP,
    SI,
    DI,

    pub fn parse(w_val: bool, reg: u3) Register {
        if (!w_val) {
            return switch (reg) {
                0b000 => .AL,
                0b001 => .CL,
                0b010 => .DL,
                0b011 => .BL,
                0b100 => .AH,
                0b101 => .CH,
                0b110 => .DH,
                0b111 => .BH,
            };
        } else {
            return switch (reg) {
                0b000 => .AX,
                0b001 => .CX,
                0b010 => .DX,
                0b011 => .BX,
                0b100 => .SP,
                0b101 => .BP,
                0b110 => .SI,
                0b111 => .DI,
            };
        }
    }
};

pub fn read_file_contents(path: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const data = try file.readToEndAlloc(allocator, file_size);
    return data;
}

// take in a slice of bytes, and print out the instruction.
pub fn parse_instruction(binary: []const u8) void {
    std.debug.assert(binary.len == 2); // mov instructions should be 2 bytes
    // get the opcode
    const opcode: u8 = binary[0] & OPCODE_MASK;
    std.debug.assert(opcode == MOV_OPCODE);
    const d_val: bool = (binary[0] & D_MASK) > 0;
    const w_val: bool = (binary[0] & W_MASK) > 0;
    const mode: Mod = Mod.parse(binary[1] & MOD_MASK);
    std.debug.assert(mode == .register_none);
    const reg: Register = Register.parse(w_val, @intCast(u3, (binary[1] & REG_MASK) >> 3));
    const r_m: Register = Register.parse(w_val, @intCast(u3, binary[1] & R_M_MASK));
    const dst = if (d_val) reg else r_m;
    const src = if (d_val) r_m else reg;
    std.debug.print("mov {s}, {s}\n", .{ @tagName(dst), @tagName(src) });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    var allocator = gpa.allocator();
    // part1:
    if (false) {
        const instruction = read_file_contents(filepath_part1_1, allocator) catch unreachable;
        parse_instruction(instruction);
    }
    if (true) {
        const asm_contents = read_file_contents(filepath_part1_2, allocator) catch unreachable;
        var i: usize = 0;
        while (i < asm_contents.len) : (i += 2) {
            const instruction = asm_contents[i .. i + 2];
            parse_instruction(instruction);
        }
    }
}
