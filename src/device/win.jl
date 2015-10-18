const CALLBACK_NULL = UInt32(0x00000000)

type WinMIDIDevice <: MIDIDevice
    # "Public" attributes
    name::AbstractString
    laststatus::UInt8 # The previous status byte written to this device
    isopen::Bool
    # "Private" attributes - platform specific, should not be referenced by the end-user.
    _devid::UInt32
    _handle::UInt32
end

type _MidiOutCaps
    wMid::UInt16
    wPid::UInt16
    vDriverVersion::UInt32
    szPname::NTuple{32, UInt8}
    wTechnology::UInt16
    wVoices::UInt16
    wNotes::UInt16
    wChannelMask::UInt16
    dwSupport::UInt32

    _MidiOutCaps() = new(0, 0, 0, ntuple(x -> 0, 32), 0, 0, 0, 0, 0)
end

function getoutputdevices()
    numberofdevices = ccall( (:midiOutGetNumDevs, :Winmm), stdcall, Int32, ())
    results = Array(WinMIDIDevice, 0)

    for i in [0:numberofdevices-1;]
        output_struct = Ref{_MidiOutCaps}(_MidiOutCaps())
        err = ccall(
            (:midiOutGetDevCapsA, :Winmm),
            stdcall,
            UInt32,
            (Ptr{UInt32}, Ref{_MidiOutCaps}, UInt32),
            Ptr{UInt32}(i),
            output_struct,
            sizeof(output_struct[])
        )

        name = bytestring(Ptr{Cchar}(pointer_from_objref(output_struct[].szPname)))
        push!(results, WinMIDIDevice(name, 0x00, false, i, 0))
    end

    results
end

function openoutputdevice(device::WinMIDIDevice)
    handle = Ref{Cint}(0)

    err = ccall((:midiOutOpen, :Winmm), stdcall,
        UInt32,
        (Ref{Cint}, UInt32, Ptr{UInt32}, Ptr{UInt32}, UInt32),
        handle, device._devid, C_NULL, C_NULL, CALLBACK_NULL)

    device._handle = handle[]
    device.isopen = true

    return device
end

function closeoutputdevice(device::WinMIDIDevice)
    ccall((:midiOutClose, :Winmm), stdcall,
        UInt32,
        (UInt32,),
        device._handle)

    device.isopen = false
    device._handle = 0

    return device
end

function writeMidiEvent(device::WinMIDIDevice, event::MIDIEvent)
    message = UInt32(0)
    status = UInt32(event.status)
    data = event.data

    if length(data) == 0
        # TODO: Handle error case
        println("ERROR, shouldn't be here")
        return "ERROR"
    end

    if length(data) == 2
        message = message | data[2]
        message = message << 8
    end

    message = message | data[1]
    message = message << 8
    message = message | status

    # https://msdn.microsoft.com/en-us/library/dd798481(v=vs.85).aspx
    result = ccall((:midiOutShortMsg, :Winmm), stdcall, UInt32, (UInt32, UInt32), device._handle, message)

    # TODO: Handle errors in a platform agnostic manner
    return result
end

testeventon = MIDIEvent(0, 0b10010000, [60, 127])
testeventoff = MIDIEvent(0, 0b10000000, [60, 127])
