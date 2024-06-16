# -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
# Potential names: localctx, peekctx,
macro scope()
    return quote
        local _mod = @__MODULE__
        local _glob = Dict(f => getfield(_mod, f) for f in names(_mod))
        local _loc = Base.@locals
        local _scope = Dict{Symbol, Any}()
        merge!(_scope, _glob, _loc)
        _scope
    end
end

# function __merge_context!(db::ContextDB, glob, loc)
#     glob = _peek_context(glob)
#     loc = _peek_context(loc)
#     dat = contextgroup(db.ctx)
#     merge!(dat, glob)
#     merge!(dat, loc)
#     db
# end

