@time begin
    using ContextFrames
    # using Distributions
    # using AbstractTrees
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--

# DOING: working in Context
# DONE: The context is literally all lite variables accesibles at the time of commit.
# It can be divided into 'globals' and 'locals'
# DOING: Create context groups... this way I can heredar from the context of other blob
# It is important to have the context duplicated to be able to search...

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
DB = ContextDB()
contextdb!(DB)
nothing

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--

# The mantraof the package is to divide 'lite' from 'non-lite' data types
# and force users to stores them in different frames.
# A Blob will be divided between 'lite' and 'non-lite' frames...
# 'lite' frames will be laoded while searching, 'non-lite' ones only on data requests.
# Include utils to get all 'glbals' and 'locals' lite variables on scope.
# the package helps to checkpoint the state of the program so we can retrive data and its context later,
# maybe even resume computation. A little bit 'matlab' style, but prioratizing 'lite' types to be stora 
# and io effitient.
# Must include '@extract' macro (Maybe use ExtractMacro.jl)

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# IDEA: maybe an @withcontext "KAKA" let ... end
let 
    clearcontext!(DB)
    contextgroup!(DB, "SAMPLE")
    SIM = "v0.1.1"

    A = 1
    B = 1
    for i in 1:2
        rn = rand()
        for j in 1:2
            cleargroup!(DB)
            # @peekcontext!(DB) 
            @litescope
        end
        for k in 1:2
            cleargroup!(DB)
            @peekcontext!(DB) 
            # @show context(DB)
        end
    end
    cleargroup!(DB)
    @peekcontext!(DB) 
    context(DB)
end

