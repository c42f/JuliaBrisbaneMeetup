module Counts

export counts

function counts(keys)
    out = Dict{eltype(keys), Int}()
    for key in keys
        if haskey(out, key)
            out[key] += 1
        else
            out[key] = 1
        end
    end
    return out
end

end # module
