using DrWatson
@quickactivate "WTGLargeScale"

include(srcdir("samsnd.jl"))
include(srcdir("samlsf.jl"))

function findztrop(pt,z,p)

    t = pt .* (p/1000).^(287/1004)
    dtdz = vcat(0,(t[3:end] .- t[1:(end-2)]) ./ (z[1:(end-2)] .- z[3:end]),0) * 1000
    ii = dtdz .< 2
    ii[z.<5000] .= 0
    iztrop = findfirst(ii)
    return z[iztrop], iztrop

end

function wforcing(z,p=zeros(length(z));ztrop,w₀,wtg,rad)

    nz = length(z)
    lsfdata = zeros(nz,7)

    lsfdata[:,1] .= z
    if !iszero(sum(p))
        lsfdata[:,2] .= p
    end

    if wtg == "DGW"
        if w₀ > 0
            w = w₀ .* (sin.(z/ztrop*pi) .- 0.2 * sin.(z/ztrop*2*pi))
        else
            w = w₀ .* (sin.(z/ztrop*pi) 
                   .-  sin.(z/ztrop*3*pi) * 0.1
                   .+  sin.(z/ztrop*4*pi) * 0.1)
        end
    elseif wtg == "SPC"
        if w₀ > 0
            w = w₀ .* (sin.(z/ztrop*pi) 
                   .-  sin.(z/ztrop*2*pi) * 0.3
                   .+  sin.(z/ztrop*4*pi) * 0.15
                   .-  sin.(z/ztrop*5*pi) * 0.1)
        else
            w = w₀ .* (sin.(z/ztrop*pi) 
                   .+  sin.(z/ztrop*2*pi) * 0.3 
                   .-  sin.(z/ztrop*3*pi) * 0.2 
                   .+  sin.(z/ztrop*4*pi) * 0.1)
        end
    end
    w[z.>ztrop] .= 0
    lsfdata[:,7] .= w
    
    return lsfdata

end

schname = "SPC"
radname = "P"
wlsvec = vcat(-1:0.2:1); wlsvec = wlsvec[.!iszero.(wlsvec)]

z,p,pt,_,_,_ = readsnd("$(rad).snd"); nz = length(z)
ztrop,iztrop = findztrop(pt,z,p)

for wls in wlsvec

    lsfname = joinpath(schname,radname,"$(wlsname(wls)).lsf")
    printlsf(lsfname,wforcing(z,p,ztrop=ztrop,w₀=wls,wtg=schname,rad=radname),1009.32)

end