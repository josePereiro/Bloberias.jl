# This interface determine if an object is lite or not
# overwrite to change definition

islite(::Any) = false    # fallback
islite(::Number) = true
islite(::Symbol) = true
islite(::DateTime) = true
islite(::VersionNumber) = true
islite(::Nothing) = true
islite(s::AbstractString) = length(s) < 256

macro litescope(prefix="")
    return quote
        local _scope = @scope($(prefix))
        filter!(_scope) do p
            islite(last(p)) || return false
            startswith(string(first(p)), "_") && return false
            return true
        end
        _scope
    end
end