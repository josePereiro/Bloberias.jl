_pidfile(rb::btBlob) = _pidfile(rb.batch)
_getlock(rb::btBlob) = _getlock(rb.batch)
_setlock!(rb::btBlob, lk) = _setlock!(rb.batch)
