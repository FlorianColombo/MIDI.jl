"""
    matchbytes(f::IO, match::AbstractString)
Reads an IO, and ensures it starts with match when interpreted as characters.
Returns false if no match and rewinds the IO afterwards. Returns true with no rewind otherwise
"""
function matchbytes(f::IO, match::AbstractString)
    bytesread = 0
    for i = 1:length(match)
        bytesread += 1
        if Char(read(f, UInt8)) != match[i]
            skip(f, -bytesread)
            return false
        end
    end
    return true
end

"""
    matchbytes(f::IO, match::Array{UInt8})
Reads an IO, and ensures it starts with match.
Returns false if no match and rewinds the IO afterwards. Returns true with no rewind otherwise
"""
function matchbytes(f::IO, match::Array{UInt8})
    bytesread = 0
    for i = 1:length(match)
        bytesread += 1
        if read(f, UInt8) != match[i]
            skip(f, -bytesread)
            return false
        end
    end
    return true
end

"""
    matchbytes(f::IO, match::UInt8)
Reads an IO, and ensures it starts with match.
Returns false if no match and rewinds the IO afterwards. Returns true with no rewind otherwise
"""
function matchbytes(f::IO, match::UInt8)
    matchbytes(f, [match])
end

function readvariablelength(f::IO)
    #=
    Variable length numbers in MIDI files are represented as a sequence of bytes.
    If the first bit is 0, we're looking at the last byte in the sequence. The remaining
    7 bits indicate the number.
    =#
    mask = 0b10000000
    notmask = ~mask
    # Read the first byte
    b = read(f, UInt8)
    bytes = UInt8[]
    if (b & mask) == 0
        # We're done here. The first bit isn't set, so the number is contained in the 7 remaining bits.
        convert(Int64, b)
    else
        result = convert(Int64, 0)
        while (b & mask) == mask
            result <<= 7
            result += (b & notmask)
            b = read(f, UInt8)
        end
        result = (result << 7) + b # No need to "& notmask", since the most significant bit is 0
        result
    end
end

function writevariablelength(f::IO, number::Int64)
    if number < 128
        write(f, UInt8(number))
    else
        bytes = UInt8[]

        unshift!(bytes, UInt8(number & 0x7F)) # Get the bottom 7 bits
        number >>>= 7 # Is there a bug with Julia here? Testing in the REPL on negative numbers give >> and >>> the same result
        while number > 0
            unshift!(bytes, UInt8(((number & 0x7F) | 0x80)))
            number >>>= 7
        end
        for b in bytes
            write(f, b)
        end
    end
end