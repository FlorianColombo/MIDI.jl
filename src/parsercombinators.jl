"A utility library for parser combinators, aimed specficially at MIDI.jl"

function lit(bytes...::UInt8) {
    f::File -> 
        read(f, UInt8)
}