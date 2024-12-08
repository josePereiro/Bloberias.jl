## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor

RefCacher() = RefCacher(Dict())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base

import Base.getindex
Base.getindex(rc::RefCacher, ref::BlobyRef) = deref!(rc, ref)