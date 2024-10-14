_pidfile(rb::raBlob) = joinpath(rablobpath(rb), "rb.pidfile")
_getlock(rb::raBlob) = get!(() -> SimpleLockFile(_pidfile(rb)), rb.temp, "_lock")
_setlock!(rb::raBlob, lk) = setindex!(rb["temp"], lk, "_lock")
