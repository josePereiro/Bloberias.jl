# -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
# CONTEXT
# -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
context(db::ContextDB) = db.ctx

context(db::ContextDB, key::String) = contextgroup(db.ctx)[key]

contextgroup(db::ContextDB, args...) = contextgroup(db.ctx, args...)
contextgroup!(db::ContextDB, args...) = contextgroup!(db.ctx, args...)
cleargroup!(db::ContextDB, args...) = empty!(contextgroup(db.ctx, args...))

clearcontext!(db::ContextDB) = empty!(db.ctx.dat)

function __merge_context!(db::ContextDB, glob, loc)
    glob = _peek_context(glob)
    loc = _peek_context(loc)
    dat = contextgroup(db.ctx)
    merge!(dat, glob)
    merge!(dat, loc)
    db
end

# -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
# Potential names: localctx, peekctx,
macro peekcontext!(db)
    return quote
        local _mod = @__MODULE__
        local _glob = Dict(f => getfield(_mod, f) for f in names(_mod))
        local _loc = Base.@locals
        local _db = $(esc(db))
        __merge_context!(_db, _glob, _loc)
        _db.ctx
    end
end
