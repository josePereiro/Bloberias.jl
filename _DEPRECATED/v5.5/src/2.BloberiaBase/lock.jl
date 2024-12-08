function _lock_obj_identity_hash(B::Bloberia, h0 = UInt64(0))::UInt64
    h = hash(h0)
    h = hash(:Bloberia, h)
    h = hash(bloberiapath(B), h)
    return h
end