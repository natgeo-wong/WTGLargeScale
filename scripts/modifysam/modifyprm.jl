using DrWatson
@quickactivate "WTGLargeScale"
using Logging
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

schname = "DGW"
radname = "P"

if schname == "DGW"
    wtgvec = [0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50]
else
    wtgvec = [sqrt(2),2,2*sqrt(2.5),5,5*sqrt(2)]
    wtgvec = vcat(wtgvec/10,1,wtgvec)
end
wlsvec = vcat(-1:0.2:2); wlsvec = wlsvec[.!iszero.(wlsvec)]

tprm  = expdir("tmp.prm")

for wtgii in wtgvec

    pwrname = powername(wtgii,schname)
    if schname == "DGW"
          wtgdmp = wtgii; wtgrlx = 1
    else; wtgrlx = wtgii; wtgdmp = 1
    end

    for wls in wlsvec

        expname = wlsname(wls)
        oprm = rundir("modifysam","prmtemplates",schname,"$(radname).prm")
        nprm = prmdir(schname,radname,expname,"$(pwrname).prm")
        open(tprm,"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[expname]" => expname)
                s = replace(s,"[en]"      => "$(imember)")
                s = replace(s,"[am]"      => @sprintf("%7e",wtgdmp))
                s = replace(s,"[tau]"     => @sprintf("%7e",wtgrlx))
                write(fprm,s)
            end
        end
        mkpath(projectdir("exp","prm",schname,radname,expname))
        mv(tprm,nprm,force=true)
        @info "Creating new prm file for $schname $radname $expname $pwrname"

    end

end
