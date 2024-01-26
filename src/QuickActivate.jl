module QuickActivate

export @quickactivate

function findproject(dir::AbstractString=pwd())
    # look for project file in current dir and parents
    home = homedir()
    while true
        for proj in Base.project_names
            file = joinpath(dir, proj)
            Base.isfile_casesensitive(file) && return dir
        end
        # bail at home directory
        dir == home && break
        # bail at root directory
        old, dir = dir, dirname(dir)
        dir == old && break
    end
    @warn "QuickActivate could not find find a project file by recursively checking " *
          "given `dir` and its parents. Returning `nothing` instead.\n(given dir: $dir)"
    return nothing
end

function get_dir_from_source(source_file)
    if source_file === nothing
        return nothing
    else
        _dirname = dirname(String(source_file))
        return isempty(_dirname) ? pwd() : abspath(_dirname)
    end
end

function quickactivate(path)
    return quote
        local projectpath = QuickActivate.findproject($path)
        if !isnothing(projectpath) && !(projectpath == dirname(Base.active_project()))
            if !@isdefined Pkg
                # this branch is primarily a hack to deal with Pluto's detection of
                # clashing names
                import Pkg as _Pkg
                _Pkg.activate(projectpath)
            else
                Pkg.activate(projectpath)
            end
        end
    end
end

macro quickactivate()
    dir = get_dir_from_source(__source__.file)
    return esc(quickactivate(dir))
end

end
