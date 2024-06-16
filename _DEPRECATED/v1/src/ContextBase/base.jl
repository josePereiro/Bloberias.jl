## ------------------------------------------------------------------
# BUILDING
## ------------------------------------------------------------------
const _CONTEXT_KEY_ALLOWED_TYPES = [String]

for T in _CONTEXT_KEY_ALLOWED_TYPES
    @eval _check_context_key(::$T) = true
    @eval _check_context_key_err(::$T) = nothing
end

_check_context_key(k) = false
_check_context_key_err(k) = _check_error("context label key", k, _CONTEXT_KEY_ALLOWED_TYPES)

## ------------------------------------------------------------------
# The reduce allowed types are to help hygine
const _CONTEXT_VAL_ALLOWED_TYPES = [String, Number, Symbol, DateTime, VersionNumber, Nothing]

for T in _CONTEXT_VAL_ALLOWED_TYPES
    @eval _check_context_val(::$T) = true
    @eval _check_context_val_err(::$T) = nothing
end

_check_context_val(v) = false
_check_context_val_err(v) = _check_error("context val", v, _CONTEXT_VAL_ALLOWED_TYPES)

## ------------------------------------------------------------------
# BASE
## ------------------------------------------------------------------
import Base.show
function show(io::IO, ctx::Context)
    print(io, "Context ")
    sep = ""
    for (g, ctx) in ctx.dat
        print(sep)
        print(io, "*", g)
        _kv_print_val(io, ctx)
        sep = "  "
    end
end

# import Base.hash
# # The order of the context labels should not matter hash(["BLA", "BLO" => 1]) == hash(["BLO" => 1, "BLA"])
# function Base.hash(ctx::Context, h::UInt)
#     h = hash(:Context, h)
#     # element hashes
#     _pairs_hs = zeros(UInt, length(ctx.dat))
#     for (i, (k, v)) in enumerate(ctx.dat)
#         _pairs_hs[i] = hash(v, hash(k, h))
#     end
#     sort!(_pairs_hs)
#     h = hash(_pairs_hs, h)
#     return h
# end
# Base.hash(ctx::Context, i::Int) = hash(ctx, UInt(i))
# Base.hash(ctx::Context) = hash(ctx, 0)

# Base.haskey
# Base.haskey(ctx::Context, key) = haskey(ctx.dat, _kv_key(key))

## ------------------------------------------------------------------
# OUTPUT
## ------------------------------------------------------------------

function contextgroup(ctx::Context)
    get!(() -> OrderedDict{String, Any}(), ctx.dat, ctx.group)
end
contextgroup!(ctx::Context, g::String) = (ctx.group = g)        # custom
contextgroup!(ctx::Context) = (ctx.group = "0")                 # default

import Base.getindex
getindex(ctx::Context, k::String) = contextgroup(ctx)[k]

## ------------------------------------------------------------------
# INPUT
## ------------------------------------------------------------------
# function _unsafe_setindex!(ctx::Context, vals...) 
#     for val in vals
#         setindex!(ctx.dat, _kv_val(val), _kv_key(val))
#     end
#     return ctx
# end

# function _safe_setindex!(ctx::Context, vals...)
#     for val in vals
#         _check_context_key_err(_kv_key(val))
#         _check_context_val_err(_kv_val(val))
#         _unsafe_setindex!(ctx, val)
#     end
#     return ctx
# end

# function _unsafe_push!(ctx::Context, )
#     for val in vals
#         _unsafe_setindex!(ctx, val)
#     end
#     return ctx
# end

# function _safe_push!(ctx::Context, vals...)
#     for val in vals
#         # check
#         k = _kv_key(val)
#         haskey(ctx, k) && error("Pushing existing key is not allowed, key: ", k)
#         v = _kv_val(val)
#         _check_context_key_err(k)
#         _check_context_val_err(v)
#         _unsafe_setindex!(ctx, val)
#     end
#     return ctx
# end

## ------------------------------------------------------------------
# UTILS
## ------------------------------------------------------------------

function _peek_context(ctx0::Dict)
    ctx = Dict()
    for (k0, v0) in ctx0
        k0 = string(k0)
        _check_context_val(v0) || continue
        ctx[k0] = v0
    end
    return ctx
end

# function _find_key(ctx::Context, k0::String)
#     for (i, k) in enumerate(keys(ctx.dat))
#         k == k0 && return i
#     end
#     return nothing
# end

# function _find_key_err(ctx::Context, k0)
#     i = _find_key(ctx, k0)
#     isnothing(i) && error("Context key not found, key: ", k0)
#     return i
# end

## ---------------------------------------------------------------------
## CONTEXT HANDLING
## ---------------------------------------------------------------------
# function _delfrom!(ctx::Context, k0::String)
#     found = false
#     for k in keys(ctx.dat)
#         found && delete!(ctx.dat, k)
#         found = found | (k == k0)
#     end
#     return found
# end

# function _findfirst_key(ctx::Context, vals...)
#     for val in vals
#         k1 = _kv_key(val)
#         for (i, k0) in enumerate(keys(ctx.dat))
#             (k0 == k1) && return k0
#         end
#     end
#     return nothing
# end

# function _build_qkvec(ctx::Context, qkvec::Vector)
    
#     kvec = []
    
#     # Handle primer
#     k0 = first(qkvec)
#     isa(k0, String) || error("Context primer must be a String, kvec: ", qkvec)
#     i0 = _find_key_err(ctx, k0)
#     for (i, val) in enumerate(ctx.dat)
#         push!(kvec, val)
#         i == i0 && break
#     end

#     # Add rest
#     for (i, val) in enumerate(qkvec)
#         i == 1 && continue
#         push!(kvec, val)
#     end
    
#     return kvec
# end

# # ## ------------------------------------------------------------------
# # # CLEAR
# # ## ------------------------------------------------------------------

# # function _clearcontext!(ctx::Context, r::AbstractArray)
# #     ks_ = collect(keys(ctx.dat))[r]
# #     foreach(ks_) do k
# #         delete!(ctx.dat, k)
# #     end
# #     return ctx
# # end

# # clearcontext!(ctx::Context) = (empty!(ctx.dat); ctx)
# # clearcontext!(ctx::Context, ::Colon) = clearcontext!(ctx)

# # function clearcontext!(ctx::Context, k::String, offset::Int = 0) 
# #     i = _find_key_err(ctx, k) + offset
# #     _clearcontext!(ctx, [i])
# # end

# # # k:(end + offset)
# # function clearcontext!(ctx::Context, k::String, ::Colon, offset::Int = 0)
# #     r = _find_key_err(ctx, k):(length(ctx.dat) + offset)
# #     _clearcontext!(ctx, r)
# # end

# # # (k + offset):(end + offset)
# # function clearcontext!(ctx::Context, k::String, offset0::Int, ::Colon, offset1::Int = 0)
# #     r = (_find_key_err(ctx, k) + offset0):(length(ctx.dat) + offset1)
# #     _clearcontext!(ctx, r)
# # end

# # # (1 + offset):(end + offset)
# # function clearcontext!(ctx::Context, offset0::Int, ::Colon, offset1::Int)
# #     r = (1 + offset0):(length(ctx.dat) + offset1)
# #     _clearcontext!(ctx, r)
# # end

# # # 1:(k + offset)
# # function clearcontext!(ctx::Context, ::Colon, k::String, offset::Int = 0)
# #     r = 1:(_find_key_err(ctx, k) + offset)
# #     _clearcontext!(ctx, r)
# # end

# # ## ------------------------------------------------------------------
