# This file controls streaming midi data to a device on your system. Windows only, until someone wants to port it to other systems and
# submit a pull request.


immutable SZPName
    c1::UInt8
    c2::UInt8
    c3::UInt8
    c4::UInt8
    c5::UInt8
    c6::UInt8
    c7::UInt8
    c8::UInt8
    c9::UInt8
    c10::UInt8
    c11::UInt8
    c12::UInt8
    c13::UInt8
    c14::UInt8
    c15::UInt8
    c16::UInt8
    c17::UInt8
    c18::UInt8
    c19::UInt8
    c20::UInt8
    c21::UInt8
    c22::UInt8
    c23::UInt8
    c24::UInt8
    c25::UInt8
    c26::UInt8
    c27::UInt8
    c28::UInt8
    c29::UInt8
    c30::UInt8
    c31::UInt8
    c32::UInt8
end

tostring(x::SZPName) = bytestring(pointer(ASCIIString([x.(z) for z in 1:length(names(x))])))

@windows ? (
type MidiOutCaps
    wMid::UInt16
    wPid::UInt16
    vDriverVersion::UInt32
    szPname::SZPName
    wTechnology::UInt16
    wVoices::UInt16
    wNotes::UInt16
    wChannelMask::UInt16
    dwSupport::UInt32

    MidiOutCaps() = new(0, 0, 0,
        SZPName(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
        0, 0, 0, 0, 0)
end
:
nothing
)


function getoutputdevices()
    @windows ? getoutputdeviceswindows() : ""
end

function getoutputdeviceswindows()
    numberofdevices = ccall( (:midiOutGetNumDevs, :Winmm), stdcall, Int32, ())
    name = Array(UInt8, 32)

    results = (AbstractString, UInt16, UInt16)[]

    for i in [0:numberofdevices-1]
        output_struct = MidiOutCaps()
        err = ccall( (:midiOutGetDevCapsA, :Winmm), stdcall, UInt32, (Ptr{UInt32}, Ptr{MidiOutCaps}, UInt32), i, &output_struct, sizeof(output_struct))
        push!(results, (tostring(output_struct.szPname), output_struct.wMid, output_struct.wPid))
    end

    results
end

const CALLBACK_NULL = uint32(0x00000000)
function openoutputdevice(id::UInt32)
    handle = uint32(0)

    err = ccall((:midiOutOpen, :Winmm), stdcall,
        UInt32,
        (Ptr{UInt32}, UInt32, Ptr{UInt32}, Ptr{UInt32}, UInt32),
        &handle, id, C_NULL, C_NULL, CALLBACK_NULL)

    println(hex(err))
    handle
end


#=
    MMRESULT midiOutOpen(
        LPHMIDIOUT lphmo, // 32?
        UINT       uDeviceID,
        DWORD_PTR  dwCallback,
        DWORD_PTR  dwCallbackInstance,
        DWORD      dwFlags
   );
=#

function initstream(device)

end


@windows ? (
    true
    :
    false
)
