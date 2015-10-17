# This file controls streaming midi data to a device on your system. Windows only, until someone wants to port it to other systems and
# submit a pull request.

const CALLBACK_NULL = UInt32(0x00000000)

type MidiOutCaps
    wMid::UInt16
    wPid::UInt16
    vDriverVersion::UInt32
    szPname::NTuple{32, UInt8}
    wTechnology::UInt16
    wVoices::UInt16
    wNotes::UInt16
    wChannelMask::UInt16
    dwSupport::UInt32

    MidiOutCaps() = new(0, 0, 0, ntuple(x -> 0, 32), 0, 0, 0, 0, 0)
end

function getoutputdevices()
    numberofdevices = ccall( (:midiOutGetNumDevs, :Winmm), stdcall, Int32, ())
    results = Array(Any, 0)

    for i in [0:numberofdevices-1;]
        output_struct = Ref{MidiOutCaps}(MidiOutCaps())
        err = ccall(
            (:midiOutGetDevCapsA, :Winmm),
            stdcall,
            UInt32,
            (Ptr{UInt32}, Ref{MidiOutCaps}, UInt32),
            Ptr{UInt32}(i), # Why Ptr instead of ref?
            output_struct,
            sizeof(output_struct[])
        )
        push!(results, (bytestring(Ptr{Cchar}(pointer_from_objref(output_struct[].szPname))), output_struct[].wMid, output_struct[].wPid))
    end

    results
end

function openoutputdevice(id::UInt32)
    handle = Ref{Cint}(1)

    err = ccall((:midiOutOpen, :Winmm), stdcall,
        UInt32,
        (Ref{Cint}, UInt32, Ptr{UInt32}, Ptr{UInt32}, UInt32),
        handle, id, C_NULL, C_NULL, CALLBACK_NULL)

    return (UInt32(handle[]), err)
end

function closeoutputdevice(id::UInt32)
    handle = UInt32(0)

    ccall((:midiOutClose, :Winmm), stdcall,
        UInt32,
        (UInt32,),
        id)
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