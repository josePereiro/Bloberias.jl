_meta(obj) = error("implement _meta(obj)::Dict for using the interface")

setmeta!(obj, key, val) = setindex!(_meta(obj), val, key)
getmeta(obj, key) = getindex(_meta(obj), key)
getmeta(obj, key, dflt) = get(_meta(obj), key, dflt)
getmeta(f::Function, obj, key) = get(f, _meta(obj), key)
getmeta!(obj, key, dflt) = get!(_meta(obj), key, dflt)
getmeta!(f::Function, obj, key) = get!(f, _meta(obj), key)