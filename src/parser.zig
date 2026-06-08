const std = @import("std");

pub const TokenType = enum {
    number,
    identifier,
    plus,
    minus,
    multiply,
    divide,
    modulo,
    power,
    lparen,
    rparen,
    lbrace,
    rbrace,
    equals,
    semicolon,
    comma,
    dot,
    @":",
    eof,
};

pub const Token = struct {
    type: TokenType,
    value: []const u8,
};

pub fn tokenize(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Token) {
    var tokens: std.ArrayList(Token) = .empty;
    errdefer tokens.deinit(allocator);
    var i: usize = 0;

    while (i < input.len) {
        const char = input[i];

        if (std.ascii.isWhitespace(char)) {
            i += 1;
            continue;
        }

        if (std.ascii.isDigit(char)) {
            const start = i;
            while (i < input.len and (std.ascii.isDigit(input[i]) or input[i] == '.')) {
                i += 1;
            }
            try tokens.append(allocator, .{
                .type = .number,
                .value = input[start..i],
            });
            continue;
        }

        if (std.ascii.isAlphabetic(char) or char == '_') {
            const start = i;
            while (i < input.len and (std.ascii.isAlphanumeric(input[i]) or input[i] == '_')) {
                i += 1;
            }
            try tokens.append(allocator, .{
                .type = .identifier,
                .value = input[start..i],
            });
            continue;
        }

        const token_type = switch (char) {
            '+' => TokenType.plus,
            '-' => TokenType.minus,
            '*' => TokenType.multiply,
            '/' => TokenType.divide,
            '%' => TokenType.modulo,
            '^' => TokenType.power,
            '(' => TokenType.lparen,
            ')' => TokenType.rparen,
            '{' => TokenType.lbrace,
            '}' => TokenType.rbrace,
            '=' => TokenType.equals,
            ';' => TokenType.semicolon,
            ',' => TokenType.comma,
            '.' => TokenType.dot,
            ':' => TokenType.@":",
            else => {
                i += 1;
                continue;
            },
        };

        try tokens.append(allocator, .{
            .type = token_type,
            .value = input[i..i+1],
        });
        i += 1;
    }

    try tokens.append(allocator, .{
        .type = .eof,
        .value = "",
    });

    return tokens;
}
