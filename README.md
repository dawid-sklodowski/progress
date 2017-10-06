Progress
========

This is implementation of simple HTTP server in Ruby, with Sinatra-like interface to create application.

Server is able to process simultaneous requests. It also provides API to ask it about requests that it processed or is currently processing. It is useful for example to show upload progressbar.

Example application allows to do simultaneous uploads and shows progress of uploads.

Run it with executable: ``` server.rb ```

It binds itself to port 2000 and listens there.

Copyright (c) 2012 [Lean Logics](http://leanlogics.com), released under the MIT license
