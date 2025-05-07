# Register turbo_stream MIME type if not already registered
# This is necessary for format.turbo_stream to work properly
Mime::Type.register "text/vnd.turbo-stream.html", :turbo_stream unless Mime::Type.lookup_by_extension(:turbo_stream)