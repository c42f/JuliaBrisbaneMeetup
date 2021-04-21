module http_server

using HTTP

function julia_main()::Cint
    HTTP.serve() do request::HTTP.Request
        @show request
        @show request.method
        @show HTTP.header(request, "Content-Type")
        @show HTTP.payload(request)
        try
            return HTTP.Response("Hello")
        catch e
            return HTTP.Response(404, "Error: $e")
        end
    end
end

end # module
