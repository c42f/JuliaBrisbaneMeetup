module jlls

function julia_main()::Cint
    if isempty(ARGS)
        dir = "."
    else
        dir = ARGS[1]
    end

    files = readdir(dir)

    for file in files
        println(file)
    end

    return Cint(0)
end

end # module
