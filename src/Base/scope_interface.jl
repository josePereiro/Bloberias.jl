# -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
# Potential names: localctx, peekctx,
macro scope()
    return quote
        local _mod = @__MODULE__
        local _glob = Dict(f => getfield(_mod, f) for f in names(_mod))
        local _loc = Base.@locals
        local _scope = Dict{String, Any}()
        for (k, v) in _glob
            _scope[string(k)] = v
        end
        for (k, v) in _loc
            _scope[string(k)] = v
        end
        _scope
    end
end