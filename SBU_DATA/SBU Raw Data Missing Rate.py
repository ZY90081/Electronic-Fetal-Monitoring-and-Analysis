import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

# Read Information Table
FileTable = pd.read_csv('E:/FHR SBU DATA/FileTable.csv', index_col=0)
DataTable = FileTable[np.isnan(FileTable['Missing'])]

chunksize = 1
index = 0
for fhr in pd.read_csv('E:/FHR SBU DATA/FHR.csv', chunksize=chunksize, iterator=True, header=None):
    if index not in DataTable.index:
        index += 1
        continue
    else:
        print('Doing No. ' + str(index))
        fhr = fhr.loc[index].values.tolist()
        fhr = np.array(fhr)
        Lfhr = np.count_nonzero(~np.isnan(fhr))
            #FileTable.at[index,'TimeLength(mins)']*60*4
        NumNaNs = fhr.size - Lfhr
        RateMissing = (Lfhr - (np.count_nonzero(fhr)-NumNaNs))/Lfhr * 100
        FileTable.loc[index, 'RateMissing'] = RateMissing
        index += 1

plt.hist(FileTable['RateMissing'], bins=20, range=(0,100))
plt.xlabel('Rate of Missing data (%)')
plt.show()

os.chdir('E:/FHR SBU DATA/')
FileTable.to_csv('FileTable.csv')
