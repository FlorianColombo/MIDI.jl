```     
        literal(bytes::UInt8...)
```
function literal(bytes::UInt8...)
    function(f::IOStream) 
        filebytes = readbytes(f, length(bytes))
        if length(filebytes) != length(bytes)
             false, [0], length(filebytes)
        else
            for i in eachindex(filebytes) 
                if filebytes[i] != bytes[i]
                    return false, [0], length(filebytes)
                end
            end
        end
        true, filebytes, length(filebytes)
    end
end

```
    uintrange(min::UInt8, max::UInt8)
```
function uintrange(min::UInt8, max::UInt8)
    function(f::IOStream)
        b = read(f, UInt8)
        if b >= min && b <= max
            true, [b], 1
        else
            false, [b], 1
        end
    end 
end

function bitset(bitnumber::UInt8)
    function(f::IOStream)
        b = read(f, UInt8)
        if (b >> bitnumber) & 1 == 1 
            true, [b], 1
        else
            false, [b], 1
        end
    end
end

function seeker(pos::Integer)
    function(f::IOStream)
        skip(f, pos)
        true, [0], 0
    end 
end

function rununtilfalse(fn::Function)
    function(f::IOStream)
        results = []
        totallength = 0
        while true
            success, value, len = fn(f)
            if success == false
                skip(f, -len)
                break
            else
                append!(results,value)
                totallength += len
            end
        end
        true, results, totallength
    end
end

function applymask(mask::UInt8)
    function(f::IOStream)
        b = read(f, UInt8)
        true, [b & mask], 1
    end
end

function and(fns::Function...)
    function(f::IOStream)
        success = false
        results = []
        totallength = 0
        for fn in fns 
            success, value, len = fn(f)
            totallength += len
            if success = false 
                break
            else
                append!(results, value)
            end
        end
        success, results, totallength
    end
end

function or(fns::Function...)
    function(f::IOStream)
        success = false
        results = []
        for fn in fns 
            success, value, len = fn(f)
            if success = false 
                skip(len)
            else
                append!(results, value)
                break
            end
        end
        success, results, totallength
    end
end

function not(fn::Function)
    function(f::IOStream)
        success, value, len = fn(f)
        !success, value, len
    end
end
