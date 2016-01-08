################################################################################
##
##   Copyright (C) 2015 - 2016 Alfred Galichon
##
##   This file is part of the R package TraME.
##
##   The R package TraME free software: you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation, either version 2 of the License, or
##   (at your option) any later version.
##
##   The R package BMR is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
##   You should have received a copy of the GNU General Public License
##   along with TraME. If not, see <http://www.gnu.org/licenses/>.
##
################################################################################

test_Logit <- function(nbDraws=1E4, seed=777, outsideOption=TRUE)
{
    set.seed(seed)
    ptm = proc.time()
    #
    print('Start of testLogit...') # Keith: change to message
    #
    U = matrix(c(1.6, 3.2, 1.1, 2.9, 1.0, 3.1),nrow=2,byrow=TRUE)
    mu = matrix(c(1, 3, 1, 2, 1, 3), nrow=2, byrow=TRUE)
    
    nbX = dim(U)[1]
    nbY = dim(U)[2]
    n = c(apply(mu,1,sum))
    #
    logits = build_logits(nbX,nbY,outsideOption=outsideOption)
    logitsSim = simul(logits,nbDraws,seed)
    #
    resG = G(logits,U,n)
    resGstar = Gstar(logits,resG$mu,n)
    resGSim = G(logitsSim,U,n)
    resGstarSim = Gstar(logitsSim,resGSim$mu,n)
    #
    print("(i) U and \nabla G*(\nabla G(U)) in (ii) cf and (iii) simulated logit:")
    print(c(U))
    print(c(resGstar$U))
    print(c(resGstarSim$U))
    
    print("G(U) in (i) cf and (ii) simulated logit:")
    print(resG$val)
    print(resGSim$val)
    print("G*(mu) in (i) cf and (ii) simulated logit:")
    print(resGstar$val)
    print(resGstarSim$val)
    #
    if(outsideOption){
        mubar = matrix(2,2,3)
        resGbar = Gbar(logits,U,n,mubar)
        resGbarS = Gbar(logitsSim,U,n,mubar)
        
        print("Gbar(mu) in (i) cf and (ii) simulated logit")
        print(resGbar$val)
        print(resGbarS$val)
    }
    #
    time = proc.time() - ptm
    print(paste0('End of testLogit. Time elapsed=', time["elapsed"], 's.')) 
}

test_Probit <- function(nbDraws=1E4, seed=777, outsideOption=TRUE)
{
    set.seed(seed)
    ptm = proc.time()
    #
    print('Start of testProbit...')
    #
    U = matrix(c(1.6, 3.2, 1.1, 2.9, 1.0, 3.1),nrow=2,byrow=T)
    mu = matrix(c(1, 3, 1, 2, 1, 3), nrow=2, byrow=T)
    
    nbX = dim(U)[1]
    nbY = dim(U)[2]
    n = c(apply(mu,1,sum))
    
    rho = 0.5
    #
    Covar = unifCorrelCovMatrices(nbX,nbY,rho,outsideOption=outsideOption)
    probits = build_probit(Covar,outsideOption=outsideOption)
    probitsSim = simul(probits,nbDraws,seed)
    #
    resGSim = G(probitsSim,U,n)
    resGstarSim = Gstar(probitsSim,resGSim$mu,n)
    #
    print("(i) U and \nabla G*(\nabla G(U)) in simulated probit:")
    print(c(U))
    print(c(resGstarSim$U))
    #
    time = proc.time() - ptm
    print(paste0('End of testProbit. Time elapsed=', time["elapsed"], 's.')) 
    
}

test_RUSC <- function(nbDraws=1E4,seed=NULL)
{
    set.seed(seed)
    ptm = proc.time()
    #
    print('Start of test_RUSC...')
    #
    U = matrix(c(1.6, 3.2, 1.1, 2.9, 1.0, 3.1),nrow=2,byrow=T)
    mu = matrix(c(1, 3, 1, 2, 1, 3), nrow=2, byrow=T)
    
    nbX = dim(U)[1]
    nbY = dim(U)[2]
    n = c(apply(mu,1,sum)) + c(1,1)
    
    zeta = matrix(1,nbX,1) %*% matrix(c(0.1, 0.2, 0.3, 0),1,nbY+1)
    #
    RUSCs = build_RUSC(zeta)
    RUSCsSim = simul(RUSCs,nbDraws,seed)  
    #
    r1 = G(RUSCs,U,n)
    r1Sim = G(RUSCsSim,U,n)
    r2 = Gstar(RUSCs,r1$mu,n)
    r2Sim = Gstar(RUSCsSim,r1Sim$mu,n)
    #
    print("G(U) in (i) cf and (ii) simulated RUSC:")
    print(c(r1$val))
    print(c(r1Sim$val))  
    #
    print("\nabla G(U) in (i) cf and (ii) simulated RUSC:")
    print(c(r1$mu))
    print(c(r1Sim$mu))  
    #
    print("(i) U and \nabla G*(\nabla G(U)) in (ii) cf and (iii) simulated RUSC:")
    print("(Note: in RUSC, (ii) should be approx equal to (iii) but not to (i)")
    print(c(U))
    print(c(r2$U))
    print(c(r2Sim$U))
    #
    r3 = Gstar(RUSCs,mu,n)
    r3Sim = Gstar(RUSCsSim,mu,n)
    #
    print("\nabla G*(mu) in (i) closed form and (ii) simulated RUSC")
    print(c(r3$U))
    print(c(r3Sim$U))
    print("G*(mu) in (i) closed form and (ii) simulated RUSC:")
    print(c(r3$val))
    print(c(r3Sim$val))
    #
    r4 = G (RUSCs,r3$U, n)
    r4Sim = G (RUSCsSim,r3Sim$U,n)
    print("\nabla G \nabla G*(mu) in (i) closed form and (ii) simulated RUSC")
    print(c(r4$mu))
    print(c(r4Sim$mu))
    #
    mubar = matrix(2,2,3)
    r5 = Gbar(RUSCs,U,n,mubar)
    r5Sim = Gbar(RUSCsSim,U,n,mubar)
    #
    print("Gbar(U,mubar) in (i) cf and (ii) simulated RUSC:")
    print(r5$val)
    print(r5Sim$val)
    print("\nabla Gbar(U,mubar) in (i) cf and (ii) simulated RUSC:")
    print(c(r5$mu))
    print(c(r5Sim$mu))
    #
    time = proc.time()-ptm
    print(paste0('End of test_RUSC. Time elapsed=', time["elapsed"], 's.')) 
}

test_RSC <- function(nbDraws=1E4,seed=NULL)
{
    set.seed(seed)
    ptm = proc.time()
    #
    print('Start of test_RSC...')
    #
    U = matrix(c(1.6, 3.2, 1.1, 2.9, 1.0, 3.1),nrow=2,byrow=TRUE)
    mu = matrix(c(1, 3, 1, 2, 1, 3), nrow=2, byrow=TRUE)
    
    nbX = dim(U)[1]
    nbY = dim(U)[2]
    n = c(apply(mu,1,sum)) + c(1,1)
    
    zeta = matrix(1,nbX,1) %*% matrix(c(0.1, 0.2, 0.3, 0),1,nbY+1)
    #
    RSCs = build_RSCbeta(zeta,2,2)
    #RSCs = build_RSCnorm(zeta)
    RSCsSim = simul(RSCs,nbDraws,seed)  
    #
    r1 = G(RSCs,U,n)
    r1Sim = G(RSCsSim,U,n)
    r2 = Gstar(RSCs,r1$mu,n)
    r2Sim = Gstar(RSCsSim,r1Sim$mu,n)
    #
    print("G(U) in (i) cf and (ii) simulated RSC:")
    print(c(r1$val))
    print(c(r1Sim$val))  
    #
    print("\nabla G(U) in (i) cf and (ii) simulated RSC:")
    print(c(r1$mu))
    print(c(r1Sim$mu))  
    #
    print("(i) U and \nabla G*(\nabla G(U)) in (ii) cf and (iii) simulated RSC:")
    print("(Note: in RSC, (ii) should be approx equal to (iii) but not to (i)")
    print(c(U))
    print(c(r2$U))
    print(c(r2Sim$U))
    #
    r3 = Gstar (RSCs,mu, n)
    r3Sim = Gstar (RSCsSim,mu,n)
    #
    print("\nabla G*(mu) in (i) closed form and (ii) simulated RSC")
    print(c(r3$U))
    print(c(r3Sim$U))
    print("G*(mu) in (i) closed form and (ii) simulated RSC:")
    print(c(r3$val))
    print(c(r3Sim$val))
    print("nabla G*(mu) in (i) closed form and (ii) simulated RSC:")
    print(r3$U)
    print(r3Sim$U)
    #
    r4 = G (RSCs,r3$U, n)
    r4Sim = G (RSCsSim,r3Sim$U,n)
    print("\nabla G \nabla G*(mu) in (i) closed form and (ii) simulated RSC")
    print(c(r4$mu))
    print(c(r4Sim$mu))
    #
    mubar = matrix(2,2,3)
    r5 = Gbar(RSCs,U,n,mubar)
    r5Sim = Gbar(RSCsSim,U,n,mubar)
    #
    print("Gbar(U,mubar) in (i) cf and (ii) simulated RSC:")
    print(r5$val)
    print(r5Sim$val)
    print("\nabla Gbar(U,mubar) in (i) cf and (ii) simulated RSC:")
    print(c(r5$mu))
    print(c(r5Sim$mu))
    #
    hess = D2Gstar.RSC(RSCs,mu,n)
    thef = function(themu) (Gstar(RSCs,themu,n)$val)
    hessNum = hessian(thef,mu)
    print("D^2G^* (i) in cf and (ii) using numerical hessian")
    print(hess)
    print(round(hessNum,6))
    #
    time = proc.time()-ptm
    print(paste0('End of test_RSC. Time elapsed=', time["elapsed"], 's.')) 
}

tests_arum <- function(notifications=TRUE)
{
    ptm = proc.time()
    #
    test_Logit()
    test_Probit()
    test_RUSC()
    test_RSC()
    #
    time = proc.time() - ptm
    #
    if(notifications){
        print(paste0('All tests of arum completed. Overall time elapsed=', time["elapsed"], 's.'))
    }
}