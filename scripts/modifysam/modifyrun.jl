using DrWatson
@quickactivate "WTGLargeScale"
using Printf

include(srcdir("sam.jl"))

schname = "DGW"
radname = "P"
email   = ""
doBuild = true

prjname = "$(schname)_$(radname)"
if schname == "DGW"
    wtgvec = [0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50]
else
    wtgvec = [sqrt(2),2,2*sqrt(2.5),5,5*sqrt(2)]
    wtgvec = vcat(wtgvec/10,1,wtgvec)
end
wlsvec = vcat(-1:0.2:1); wlsvec = wlsvec[.!iszero.(wlsvec)]

mrun = projectdir("run","modifysam","runtemplates","modelrun.sh")
brun = projectdir("run","modifysam","runtemplates","Build.csh")

open(mrun,"r") do frun
    s = read(frun,String)
    for wls in wlsvec
        expname = wlsname(wls)
        for wtgii in wtgvec
            wtgname = powername(wtgii,schname)
            for ensembleii in 1 : 3

                mstr = @sprintf("%02d",ensembleii)
                nrun = projectdir("run",schname,radname,expname,"$(wtgname).sh")
                open(nrun,"w") do wrun
                    sn = replace(s ,"[email]"   => email)
                    sn = replace(sn,"[dirname]" => projectdir())
                    sn = replace(sn,"[schname]" => schname)
                    sn = replace(sn,"[radname]" => radname)
                    sn = replace(sn,"[expname]" => expname)
                    sn = replace(sn,"[memberx]" => "member$(mstr)")
                    write(wrun,sn)
                end

            end
        end
    end
end

if doBuild
    open(brun,"r") do frun
        s = read(frun,String)
        for wls in wlsvec
            expname = wlsname(wls)
            for wtgii in wtgvec
                wtgname = powername(wtgii,schname)
                nrun = projectdir("run",schname,radname,expname,"Build.csh")
                open(nrun,"w") do wrun
                    sn = replace(s ,"[datadir]" => datadir())
                    sn = replace(sn,"[schname]" => schname)
                    sn = replace(sn,"[radname]" => radname)
                    sn = replace(sn,"[expname]" => expname)
                    write(wrun,sn)
                end
            end
        end
    end
end