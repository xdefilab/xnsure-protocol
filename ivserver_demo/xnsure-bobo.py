import bobo
import numpy as np
import pandas as pd
import scipy.stats as sps

def capped_call_iv(spotprice,price2eth,strikestart,strikeend,totalTime,fundingAPY):
    #spotprice = 420.0
    #price2eth = 0.05
    diff = 999.9
    #strikestart = 400.0
    #strikeend = 500.0
    finalv = 0.0
    for i in range(2000,5,-1):
        v = 5e-6 * i
        d11=(np.log(spotprice/strikestart)+(fundingAPY/(86400*365/13.1)+v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        d12=(np.log(spotprice/strikestart)+(fundingAPY/(86400*365/13.1)-v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        d21=(np.log(spotprice/strikeend)+(fundingAPY/(86400*365/13.1)+v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        d22=(np.log(spotprice/strikeend)+(fundingAPY/(86400*365/13.1)-v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        q = sps.norm.cdf(d11) * spotprice - strikestart * np.exp( -fundingAPY/(86400*365/13.1)*totalTime)*sps.norm.cdf(d12)- \
             (sps.norm.cdf(d21) * spotprice - strikeend * np.exp( -fundingAPY/(86400*365/13.1)*totalTime)*sps.norm.cdf(d22))
        newdiff = np.fabs(q  - price2eth * spotprice)
        if newdiff < diff:
            finalv = v
            diff = newdiff
        #print(v,q)
    #print(finalv*np.sqrt(86400/13.1*365)*100)
    return finalv*np.sqrt(86400/13.1*365)*100
    
    
def capped_put_iv(spotprice,price2usdt,strikestart,strikeend,totalTime,fundingAPY):
    #spotprice = 420.0
    #price2eth = 0.05
    diff = 999.9
    #strikestart = 400.0
    #strikeend = 500.0
    finalv = 0.0
    for i in range(2000,5,-1):
        v = 5e-6 * i
        d11=(np.log(spotprice/strikestart)+(fundingAPY/(86400*365/13.1)+v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        d12=(np.log(spotprice/strikestart)+(fundingAPY/(86400*365/13.1)-v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        d21=(np.log(spotprice/strikeend)+(fundingAPY/(86400*365/13.1)+v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        d22=(np.log(spotprice/strikeend)+(fundingAPY/(86400*365/13.1)-v**2.0/2.0)*totalTime)/(v*np.sqrt(totalTime))
        q = - sps.norm.cdf( - d11) * spotprice + strikestart * np.exp( -fundingAPY/(86400*365/13.1)*totalTime)*sps.norm.cdf(-d12)- \
             ( - sps.norm.cdf( - d21) * spotprice + strikeend * np.exp( -fundingAPY/(86400*365/13.1)*totalTime)*sps.norm.cdf(-d22))
        newdiff = np.fabs(q  - price2usdt)
        if newdiff < diff:
            finalv = v
            diff = newdiff
        #print(v,q)
    #print(finalv*np.sqrt(86400/13.1*365)*100)
    return finalv*np.sqrt(86400/13.1*365)*100
    

@bobo.query('/')
def capped_iv(direction,spotprice,price,strikestart,strikeend,totalTime,fundingAPY):
    if direction == "CALL":
        return str(capped_call_iv(np.float(spotprice),np.float(price),np.float(strikestart),np.float(strikeend),np.float(totalTime),np.float(fundingAPY)))
    elif direction == "PUT":
        return str(capped_put_iv(np.float(spotprice),np.float(price),np.float(strikestart),np.float(strikeend),np.float(totalTime),np.float(fundingAPY)))
    else:
        return ""


    

