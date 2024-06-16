## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Just a wrapper to dispatch context specific methods
# TODO: Make blob references: for instance a gropu cold be a ref to other blob group
mutable struct Context
    group::String                                           # Current open group
    dat::OrderedDict{String, OrderedDict{String, Any}}      # "group" => context
end
Context() = Context("0", OrderedDict())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# |--- 0...<<h=0x86ff87788a342>>      (batch of group '0')
#     |--- meta.jls                   (batch meta data [Dict])
#     |--- ctx.frame.jls              (RESERVED frame for context data [Vector{Dict}])
#     |--- 0.frame.jls                (default data frame with name '0' [Vector{Dict}])
#     |--- bla.frame.jls              (data frame with name 'bla' [Vector{Dict}])
mutable struct ContextBatch
    # paths
    root::String
    
    # data
    meta::Dict{String, Any}
    frames::Dict
    
    # data
    extras::Dict 
end
ContextBatch() = ContextBatch("", Dict(), Dict(), Dict())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Just a wrapper to dispatch blob specific methods
mutable struct ContextBlob
    dat::OrderedDict{String, Any}
end
ContextBlob() = ContextBlob(OrderedDict())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
mutable struct ContextDB
    # paths
    root::String
    
    # stage [RAM DATA]
    ctx::Context                         # current context
    stage::ContextBlob                   # current uncommited blob data

    # batch
    # At set/get actions the loaded current batch is used
    # At commit/query new/ondisk batches must be required
    batch::ContextBatch
    
    # extras
    extras::Dict{String, Any}            # spare space

end
ContextDB(root) = ContextDB(root, Context(), ContextBlob(), ContextBatch(), Dict())
ContextDB() = ContextDB("")

# import Base.show
# Base.show(db::ContextDB) = println(io, "ContextDB(\"", db.root, "\")")
