# This file controls streaming midi data to a device on your system. Windows only, until someone wants to port it to other systems and
# submit a pull request.


immutable SZPName
    c1::Uint8
    c2::Uint8
    c3::Uint8
    c4::Uint8
    c5::Uint8
    c6::Uint8
    c7::Uint8
    c8::Uint8
    c9::Uint8
    c10::Uint8
    c11::Uint8
    c12::Uint8
    c13::Uint8
    c14::Uint8
    c15::Uint8
    c16::Uint8
    c17::Uint8
    c18::Uint8
    c19::Uint8
    c20::Uint8
    c21::Uint8
    c22::Uint8
    c23::Uint8
    c24::Uint8
    c25::Uint8
    c26::Uint8
    c27::Uint8
    c28::Uint8
    c29::Uint8
    c30::Uint8
    c31::Uint8
    c32::Uint8
end

tostring(x::SZPName) = bytestring(pointer(ASCIIString([x.(z) for z in 1:length(names(x))])))

@windows ? (
type MidiOutCaps
    wMid::Uint16
    wPid::Uint16
    vDriverVersion::Uint32
    szPname::SZPName
    wTechnology::Uint16
    wVoices::Uint16
    wNotes::Uint16
    wChannelMask::Uint16
    dwSupport::Uint32

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
    name = Array(Uint8, 32)

    results = (String, Uint16, Uint16)[]

    for i in [0:numberofdevices-1]
        output_struct = MidiOutCaps()
        err = ccall( (:midiOutGetDevCapsA, :Winmm), stdcall, Uint32, (Ptr{Uint32}, Ptr{MidiOutCaps}, Uint32), i, &output_struct, sizeof(output_struct))
        push!(results, (tostring(output_struct.szPname), output_struct.wMid, output_struct.wPid))
    end

    results
end

const CALLBACK_NULL = uint32(0x00000000)
function openoutputdevice(id::Uint32)
    handle = uint32(0)

    err = ccall((:midiOutOpen, :Winmm), stdcall,
        Uint32,
        (Ptr{Uint32}, Uint32, Ptr{Uint32}, Ptr{Uint32}, Uint32),
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
