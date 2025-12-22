import sys
from typing import Iterator


def lexer(file: str) -> Iterator[str]:
    WHITESPACE = [" ", "\n"]
    cur_index = 0
    cur_len = 1

    # skip whitespace + comments
    while cur_index < len(file) and (
        file[cur_index] in WHITESPACE or file[cur_index] == ";"
    ):
        while cur_index < len(file) and file[cur_index] in WHITESPACE:
            cur_index += 1
        if cur_index < len(file) and file[cur_index] == ";":
            while cur_index < len(file) and file[cur_index] != "\n":
                cur_index += 1
            cur_index += 1  # skip newline

    # move cur_len until whitespace
    while cur_index < len(file):
        while (
            cur_index + cur_len < len(file)
            and file[cur_index + cur_len] not in WHITESPACE
        ):
            cur_len += 1
        token = file[cur_index : cur_index + cur_len]
        yield token

        # move cur_index up, skipping whitespaces
        cur_index += cur_len
        cur_len = 1
        # skip whitespace + comments
        while cur_index < len(file) and file[cur_index] in WHITESPACE:
            while cur_index < len(file) and file[cur_index] in WHITESPACE:
                cur_index += 1
            if cur_index < len(file) and file[cur_index] == ";":
                while cur_index < len(file) and file[cur_index] != "\n":
                    cur_index += 1
                cur_index += 1  # skip newline


def operand_str_to_byte(op: str) -> bytes:
    base = 10
    if len(op) >= 2:
        if op[:2] == "0x":
            base = 16
            op: str = op[2:]
        elif op[:2] == "0b":
            base = 2
            op: str = op[2:]

    return bytes([int(op, base=base)])


def assemble(tokens: Iterator[str]) -> bytearray:
    INSTR_TO_BYTE = {
        "LDA": b"\x00",
        "LDX": b"\x01",
        "ADD_IMD": b"\x02",
        "ADDX": b"\x03",
        "SUB_IMD": b"\x04",
        "SUBX": b"\x05",
        "JMP": b"\x06",
        "JEQ": b"\x07",
        "JNE": b"\x08",
        "JGT": b"\x09",
        "JLT": b"\x0a",
        "JGE": b"\x0b",
        "JLE": b"\x0c",
        "CMP_IMD": b"\x0d",
        "CMPX": b"\x0e",
        "TAX": b"\x0f",
        "TXA": b"\x10",
        "TAY": b"\x11",
        "TYA": b"\x12",
    }

    out = bytearray([0] * 256)
    for i, token in enumerate(tokens):
        if token in INSTR_TO_BYTE:
            # instr
            out[i : i + 1] = INSTR_TO_BYTE[token]
        else:
            # operand
            out[i : i + 1] = operand_str_to_byte(token)

    return out


def main():
    in_path = sys.argv[1]
    out_path = "./prog.mem"
    print(f"assembling {in_path}...")

    with open(in_path, "rt") as f:
        file = f.read()

    tokens = lexer(file)
    out = assemble(tokens)

    # convert to verilog readmemh format (hex string, one byte per line)
    out_str = "".join([format(b, "02x") + "\n" for b in out])

    with open(out_path, "wt") as f:
        f.write(out_str)


if __name__ == "__main__":
    main()
