## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor

RefCacher() = RefCacher(Dict())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base

import Base.getindex
Base.getindex(rc::RefCacher, ref::BlobyRef) = deref(rc, ref)

import Base.empty!
Base.empty!(rc::RefCacher) = empty!(rc.depot_cache)