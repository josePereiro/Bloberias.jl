function _field_hash(obj, h = 0)
    h = hash(h)
    for f in fieldnames(typeof(obj))
        v = getfield(obj, f)
        _valid_type = false
        _valid_type |= isa(v, String)
        _valid_type |= isa(v, Symbol)
        _valid_type |= isa(v, Integer)
        _valid_type || continue
        h = hash(v, h)
    end
    return h
end

function _col_hash(col, h = 0)
    h = hash(h)
    for el in col
        h = hash(el, h)
    end
    return h
end

function _pidfile_path(bo::BlobyObj, args...; B = bloberia(bo))
    root = bloberia_dir(B)
    _hash = _field_hash(bo, 0)
    _hash = _col_hash(args, _hash)
    _name = string(typeof(bo), ".", repr(_hash), ".pidfile")
    return joinpath(root, "_locks", _name)
end

function getlockfile(bo::BlobyObj, args...) 
    B = bloberia(bo)
    # filepath
    _file = _pidfile_path(bo, args...; B)
    get!(B.temp, _file) do
        return SimpleLockFile(_file)
    end
end

import Base.lock
function Base.lock(f::Function, bo::BlobyObj, args...; kwargs...) 
    lk = getlockfile(bo, args...)
    lock(f, lk; kwargs...)
end

function Base.lock(bo::BlobyObj, args...; kwargs...) 
    lk = getlockfile(bo, args...)
    lock(lk; kwargs...)
    return bo
end

import Base.islocked
function Base.islocked(bo::BlobyObj, args...) 
    lk = getlockfile(bo, args...)
    isnothing(lk) && return false
    return islocked(lk)
end

import Base.unlock
function Base.unlock(bo::BlobyObj, args...; force = false) 
    lk = getlockfile(bo, args...)
    isnothing(lk) && return # ignore
    return unlock(lk; force)
end
    
# function unlock_batches(B::Bloberia; force = true)
#     for bb in B
#         unlock(bb; force)
#     end
# end