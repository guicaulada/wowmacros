"""Small Lua 5.1 lexical compactor and lossless UTF-8 macro chunker.

No syntax rewriting: strings are byte-preserved; comments and redundant whitespace
are removed. A separator is retained whenever adjacent tokens would merge.
"""
import re

WORD = re.compile(r'[A-Za-z_][A-Za-z_0-9]*')
NUMBER = re.compile(r'(?:0[xX][0-9a-fA-F]+(?:\.[0-9a-fA-F]*)?(?:[pP][+-]?\d+)?|(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?)')
LONG = re.compile(r'\[(=*)\[')


def tokens(source):
    result = []
    position = 0
    while position < len(source):
        if source[position].isspace():
            position += 1
            continue
        comment = source.startswith('--', position)
        start = position + 2 if comment else position
        long = LONG.match(source, start)
        if long:
            delimiter = ']' + long[1] + ']'
            end = source.find(delimiter, long.end())
            if end < 0:
                raise ValueError('Unterminated Lua long string/comment')
            end += len(delimiter)
            if not comment:
                result.append(source[position:end])
            position = end
        elif comment:
            end = source.find('\n', start)
            position = len(source) if end < 0 else end + 1
        elif source[position] in "\"'":
            quote = source[position]
            end = position + 1
            while end < len(source) and source[end] != quote:
                end += 2 if source[end] == '\\' else 1
            if end >= len(source):
                raise ValueError('Unterminated Lua quoted string')
            result.append(source[position:end + 1])
            position = end + 1
        else:
            match = WORD.match(source, position) or NUMBER.match(source, position)
            if match:
                token = match[0]
            else:
                token = next((s for s in ('...', '..', '==', '~=', '<=', '>=', '::')
                              if source.startswith(s, position)), source[position])
            result.append(token)
            position += len(token)
    return result


def compact(source):
    parts = tokens(source)
    output = []
    for index, token in enumerate(parts):
        if index:
            previous = parts[index - 1]
            try:
                separated = tokens(previous + token) != [previous, token]
            except ValueError:
                separated = True
            # Lua's numeral lexer consumes dots more greedily than NUMBER does.
            if NUMBER.fullmatch(previous) and (token.startswith('.') or re.match(r'[A-Za-z_]', token)):
                separated = True
            # Three individually valid tokens can otherwise become a long opener.
            if previous == '[' and token == '=':
                separated = True
            if separated:
                output.append(' ')
        output.append(token)
    return ''.join(output)


def split(source, limit=255):
    """Keep each fragment valid UTF-8, with exact concatenation and no added bytes."""
    chunks, current, size = [], [], 0
    for character in source:
        width = len(character.encode('utf-8'))
        if width > limit:
            raise ValueError('Chunk size cannot hold a UTF-8 character')
        if size + width > limit:
            chunks.append(''.join(current))
            current, size = [], 0
        current.append(character)
        size += width
    if current or not chunks:
        chunks.append(''.join(current))
    return chunks
