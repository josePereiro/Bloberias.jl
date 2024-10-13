import Serialization.serialize
Serialization.serialize(vb::btBlob; ignoreempty = false) = 
    serialize(vb.batch; ignoreempty) 

import Serialization.serialize
Serialization.serialize(vb::btBlob, frame::AbstractString; ignoreempty = true) = 
    Serialization.serialize(vb.batch, frame; ignoreempty)
