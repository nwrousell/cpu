import sys
from typing import Iterator
from string import whitespace


class Lexer:
    def __init__(self, file: str):
        self.file = file
        self.cur_index = 0

    def skip_whitespace(self):
        """
        increments cur_index until file[cur_index] is on start of token or comma.
        """
        while (
            self.cur_index < len(self.file) and self.file[self.cur_index] in whitespace
        ):
            self.cur_index += 1

    def maybe_skip_comma(self) -> bool:
        """
        skips comma past newline if present. returns whether was comma. file[cur_index] may be on whitespace or start of token.
        """
        if self.cur_index < len(self.file) and self.file[self.cur_index] == ";":
            while self.cur_index < len(self.file) and self.file[self.cur_index] != "\n":
                self.cur_index += 1
            self.cur_index += 1  # skip newline
            return True
        return False

    def __next__(self) -> str:
        # skip until start of token
        self.skip_whitespace()
        while self.maybe_skip_comma():
            self.skip_whitespace()

        cur_len = 0
        inside_quotes = False
        while self.cur_index + cur_len < len(self.file) and (
            self.file[self.cur_index + cur_len] not in whitespace or inside_quotes
        ):
            if self.file[self.cur_index + cur_len] == "'":
                inside_quotes = not inside_quotes
            cur_len += 1

        if cur_len == 0:
            raise StopIteration
        else:
            token = self.file[self.cur_index : self.cur_index + cur_len]
            self.cur_index += cur_len
            return token

    def __iter__(self) -> Iterator[str]:
        return self


def operand_str_to_byte(op: str) -> bytes:
    base = 10
    if len(op) >= 2:
        if op[:2] == "0x":
            base = 16
            op: str = op[2:]
        elif op[:2] == "0b":
            base = 2
            op: str = op[2:]
        elif op[0] == "'":
            op = ord(op[1:-1])
            if op > 255:
                raise Exception(
                    f"in operand_str_to_byte received invalid ascii byte: {op}"
                )

    if isinstance(op, str):
        op = int(op, base=base)
    return bytes([op])


def assemble(tokens: Lexer) -> bytearray:
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
        "HLT": b"\x13",
        "DSP": b"\x14",
        "STA": b"\x15",
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

    tokens = Lexer(file)
    out = assemble(tokens)

    # convert to verilog readmemh format (hex string, one byte per line)
    out_str = "".join([format(b, "02x") + "\n" for b in out])

    with open(out_path, "wt") as f:
        f.write(out_str)


if __name__ == "__main__":
    main()
