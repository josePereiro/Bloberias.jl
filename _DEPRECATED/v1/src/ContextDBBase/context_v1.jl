# # -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
# # CONTEXT
# # -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
# context(db::ContextDB) = db.ctx

# context(db::ContextDB, key::String) = db.ctx[key]

# function context!(db::ContextDB, vals...) 
#     _k0 = _findfirst_key(db.ctx, vals...)
#     !isnothing(_k0) && _delfrom!(db.ctx, _k0)
#     for val in vals
#         _safe_setindex!(db.ctx, val)
#     end
# end
# function context!(db::ContextDB; kwargs...) 
#     for (k, v) in kwargs
#         _safe_push!(db.ctx, string(k) => v)
#     end
# end

# # Ignore bad types
# function peekcontext!(db::ContextDB, vals...) 
#     vals = filter(vals) do val
#         _check_context_key(_kv_key(val)) && return false
#         _check_context_val(_kv_val(val)) && return false
#         return true
#     end
#     context!(db, vals...)
# end


# # -- .- .-- -. . ---- .- .- . -.. - -- -.. --- -...
# # Potential names: localctx, peekctx,
# function _peek_ctx(vars0::Dict)
#     lites = Dict{Symbol, Any}()
#     for (k, v) in vars0
#         any(T -> isa(v, T), [Number, AbstractString, Symbol]) || continue
#         lites[k] = v
#     end
#     return lites
# end

# macro peekctx()
#     return quote
#         local _vars = Base.@locals()
#         return _peek_ctx(_vars)
#     end
# end
