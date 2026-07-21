
import pandas as pd
import os 
from datetime import date 
from pyxirr import xirr 

filePath = "./py_tools"
fileName = "mf_data.csv"
fileNameFull = filePath + "/" + fileName

####################
# 
####################
def processCsv():
    # print("Inside processCsv")

    dfMf = pd.DataFrame()

    dfMf = pd.read_csv(fileNameFull , header=0)
    # print(dfMf)

    nameMf = dfMf["Scrip"]
    nameMfSet = set(nameMf)
    print("-------------------------------------------------------")
    for currMfName in nameMfSet:
        # print(currMfName)
        # continue

        dfXirrData = dfMf[dfMf['Scrip'] == currMfName]
        # print(dfXirrData)

        dfTmp = dfXirrData[dfXirrData['Type'] == 'Current'].reset_index()
        currDate = dfTmp.loc[0 ,'Date']

        dfXirrData = dfXirrData[["Date","Amount"]]
        dfXirrData = dfXirrData.apply(lambda z : z.str.replace(",","") )
        dictXirr = { 'Amount' : float }
        dfXirrData = dfXirrData.astype(dictXirr)
        dfXirrData["Date"] = pd.to_datetime(dfXirrData["Date"]  , dayfirst=True)

        

        x = xirr(dfXirrData)

        print("As of {}, for ~{}~ XIRR is {:.3f} ".format(currDate , currMfName , x*100)   )

    print("-------------------------------------------------------")

####################
# XYZ
####################

def main():
    # print("Inside main -11.7")

    processCsv()


if __name__ == "__main__":
    main()
