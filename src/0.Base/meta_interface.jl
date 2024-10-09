_meta(obj)::OrderedDict = error("implement _meta(obj)::OrderedDict for using the interface")

getmeta(obj) = _meta(obj)
setmeta!(obj, key, val) = setindex!(_meta(obj), val, key)
getmeta(obj, key) = getindex(_meta(obj), key)
getmeta(obj, key, dflt) = get(_meta(obj), key, dflt)
getmeta(f::Function, obj, key) = get(f, _meta(obj), key)
getmeta!(obj, key, dflt) = get!(_meta(obj), key, dflt)
getmeta!(f::Function, obj, key) = get!(f, _meta(obj), key)