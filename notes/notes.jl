# TODO: create bloberia(::AbstractBlob), etc kind of accessor interfaces

# DONE: BlobyRef
# - An object containuing all data for pointing to a BlobyObject/Val
# - Its main goald is to be cheap to serialized
# - It must serialized the expected return type

# TODO: Work on type stability

# TODO: Dry the code: a lot of code repetition

# TODO: Define/Document the load on demand behaviour 
#   - load if it is missing on ram
#   - for reloading you must empty the cache
#   - maybe have a blob(::Blob) method for shadow copy

# DONE: create a multifile raBlob system
# - Ex: blob!(B, "globals", "ecoli_core", "net0") will create/load "ecoli_core.globals.net0.jls" file
# - blob!(B, "globals", "ecoli_core", "net0.elep0")
# - blob!(B, "globals", "ecoli_core") will create/load all files matching
# - a raBlob might target multiple files
# - One complexity is that at setindex/serialization you must decide where to write the new data
# - The goal is to create a frame-like structure to separate heavy objs into diferent files but handle it from a single blob object.

# DONE:
# - Make random blobs hold its content
# - that is, move it away from Bloberias
# - otherwise you can not load other rablobs at the same time
# think about raBlob as a batch of a single blob, so it needs to have batch+blob functionality


# OLD --.- - -- - -- - -

# IDEAS v1:

# 1. Definition of Context

# 1.1 Computation/Problem point of view
# - The context is the parameters that affects the computation at hand.
# - The implementation details shouldn't be included

# 1.2 Script point of view
# - Here context are just all variables that are present at the moment of saving the data.
# - It is irrelevant if those variables are relevant for the calculation or not. 
# - FAVORITE: This is the more general, giving that must of the time, one must explicitly 
# have the parameters of a computation contain in variables. 
#     - Additionally, it is not dificult to extend the interface for including custom types.
#     - For instance, custom types might be rolled out and store only its 'lite' typed fields.

# 1.3 Context as a path on the data base
# - Here for instance, the order of the context is important.

# 1.4 Mixed

# 1.41 Context as a Tree
# - The context is just a directed tree...
# - In this case order might matter
# - A context is totally defined by the subtree that is unique to it. 

# 1.42 Context as a key value collection
# - PREFERED beacuse its simplicity
# - In this order might not matter
# - Context is just a Dict like structure
# - A context is defined by the key-value pair subset which is unique to it.

# 2. Context definition interface

# 2.1 Automatic vs manual context definition

# - All by default
#     - I can use all available 'lite' typed (Numbers, short strings, etc) variables as context.
#     - I can have a configurable 'ignore'/'include' stratergy.

# - Manual declaration of context
#     - inline macros.
#     - Have a context registry, keep the symbols to track.

# - Mix approach 
#     - have all the above functionalities.
#     - have a 'localcontext' function which extract the context given the available variables.

# 3. Context Batches, Frames and Batches definition. 

# - All this mess is for performance reasons.
# - Data can be consived as a continuos OrderedDict{uuid, ContextBlob} structure.
# - But, for performance reasons this data is splitted first in batches (each one containing a given number of Blobs).
# - Each batch is at the same time splitted in frames, but this spliting is not in the same dimention. Each blob of the batch is divided in frames, each one containing the same field of all of them.
# - That is, in a batch we will have:
#     frame12: [blob123.fields12, blob124.fields12, blob125.fields12, ....]
#     frame4:  [blob123.fields4 , blob124.fields4 , blob125.fields4 , ....]
# - Additionally, we can have a "meta" field for each batch to store extra lite data of the whole batch.
# - This way in memory is typically loaded as maximum a whole batch, but potentialy, only a few frames of the batch itself.
# - A blob is a 'key' => 'value' structure
# - each context is identifyed by an universaly unique identifier.

# 4. Writing/Input interafce

# - Must have staging

# 5. Reading/output interface.

# - IMPORTANT: Do not make it complicated... simplicity is important for reusing...

# 5.1 Query
# - Pattern matching based
# - Should use multi threading
# - Mush have Product Query capabilities (ej: collect A => 1:3, B => [-1, 2])
# - Should always work on contexts. Opionally also non-lite data. 

# 5.2 Get
# - Given a precise location, load it.

# 5.3 Iterator
# - Itarate all blobs batch after batch...

# 5.4 QueryRes
# - Use the iteration interface to find all matching contexts/data...
# - Returns a new object that can be iterated, but this time only over the 
# batches that have at least hit...

# 6. Disk layout

# ---- db                                 (root dir)
#     |--- config.jls                     (optional  [Dict])
#     |--- meta.jls                       (optional [Dict])
#     |--- 0...<<h=0x86ff87788a342>>      (batch of group '0')
#         |--- meta.jls                   (batch meta data [Dict])
#         |--- ctx.frame.jls              (reserved frame for context data [Vector{Dict}])
#         |--- 0.frame.jls                (default data frame with name '0' [Vector{Dict}])
#         |--- bla.frame.jls              (data frame with name 'bla' [Vector{Dict}])
#     |--- bla...<<h=0x761aff765a578>>      (batch of group 'bla')



# 7. (Des)Serialization
# - frames are serialized Dict objects
# - At deserializing they are wrapped into an ContextBlob (if necessary)
# - All query/get operations (ej: haskey) are performed on the loaded frames.
# - That is, frames should be loaded explicitly, except default frames which are loaded on demand.

# 9. Utils

# 9.1 PinFiles

# 9.2 Repair capabilities & diagnostics

# 9.3 Implement Iterator interface

# 9.3.1 'foreach' blob
# - Add :break, :continue interface
# - return last value of the function

# 9.3.2 for blob in db/batch/frame


# # TO IMPLEMENT FIRST

# - Main input form: push to a loaded batch
# - Main output form: iter each batch/blob
# - Basically, BlobBatches with Context objects

# =#