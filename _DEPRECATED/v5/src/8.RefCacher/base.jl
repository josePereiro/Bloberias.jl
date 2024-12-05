import Base.getindex
Base.getindex(rc::RefCacher, ref::BlobyRef) = deref!(rc, ref)