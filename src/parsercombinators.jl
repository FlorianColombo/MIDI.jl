```     
        literal(bytes::UInt8...)
        literal matches an array of bytes or returns false
```
function literal(bytes::UInt8...)
    function(f::IOStream) 
        read_bytes = read(f, UInt8)
        if length(f) != length(bytes)
            false
        else
            for i in eachindex(read_bytes) 
                if read_bytes[i] != bytes[i] 
                    return false
                end
            end
        end
        bytes
    end
end
