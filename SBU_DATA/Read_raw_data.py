# This code is for reading raw .csv sheets
# unfinished!


import glob
import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt



birthtimes = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/birth_times.csv', index_col='PERSON_ID')
mflink = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/mother_child_link.csv',index_col='CHILD_PERSON_ID')
mflink['birth_times'] = birthtimes

nicu = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/infants_IDs_admitted_to_nicu.txt',
                   header=None).values.reshape(-1)
delayed = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/infants_IDs_with_delayed_transition.txt',
                      header=None).values.reshape(-1)
enceph = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/infants_IDs_with_encephalopathy.txt',
                     header=None).values.reshape(-1)
hypoxia = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/infants_IDs_with_hypoxia.txt',
                      header=None).values.reshape(-1)
perdep = pd.read_csv(
    '/Users/liuyang/Desktop/Version2 IssueLabel/infants_IDs_with_perinatal_depression.txt',
    header=None).values.reshape(-1)
respiratory = pd.read_csv(
    '/Users/liuyang/Desktop/Version2 IssueLabel/infants_IDs_with_respiratory_distress.txt',
    header=None).values.reshape(-1)
mflink.loc[nicu, 'nicu'] = 1
mflink.loc[delayed, 'delayed'] = 1
mflink.loc[enceph, 'enceph'] = 1
mflink.loc[hypoxia, 'hypoxia'] = 1
mflink.loc[perdep, 'perdep'] = 1
mflink.loc[respiratory, 'respiratory'] = 1

# check duplication and delete the recordings with the same child id and mother id
childID = mflink.index
mflink['CHILD_PERSON_ID'] = childID
dpChildMom = mflink.duplicated(subset=['CHILD_PERSON_ID','MOTHER_PERSON_ID'], keep='first')
mflink['checkdp'] = dpChildMom
mflink = mflink[mflink.checkdp == False]
del mflink['checkdp']
#duplications = mflink[mflink.checkdp == True]

# get last_hour_v1
os.chdir('/Users/liuyang/Desktop/Version2 IssueLabel/last_hour_signals_v1')  # change directory
results = pd.Series([i for i in glob.glob('*')])
idxsig = pd.DataFrame(np.ones(results.size), index=[float(i[:8].replace('_', '')) for i in glob.glob('*')])
data = pd.DataFrame(index=idxsig.index)
print("# of signals in resluts folder is:")
print(idxsig.shape[0])
mflink['v1signal?'] = idxsig

# get last_hour_v2
os.chdir('/Users/liuyang/Desktop/Version2 IssueLabel/last_hour_signals_v2/results')  # change directory
results = pd.Series([i for i in glob.glob('*')])
idxsig = pd.DataFrame(np.ones(results.size), index=[float(i[:8].replace('_', '')) for i in glob.glob('*')])
data = pd.DataFrame(index=idxsig.index)
print("# of signals in resluts folder is:")
print(idxsig.shape[0])
mflink['v2signal?'] = idxsig
mflink = mflink.replace(np.nan, 0)

# analyze labels
sum_column = mflink['nicu'] + mflink['delayed'] + mflink['enceph'] + mflink['hypoxia'] + mflink['perdep'] + mflink['respiratory']
mflink['labels'] = sum_column

os.chdir('/Users/liuyang/Desktop/Version2 IssueLabel')  # change back
#mflink = mflink[mflink['v1signal?'] == 1]

#child_id_count = mflink.index.value_counts()
#mflink = mflink[child_id_count == 1]
#%%
#mflink.loc[:, 'MOTHER_PERSON_ID'].value_counts().value_counts()
#mflink.loc[:, 'MOTHER_ENCNTR_ID'].value_counts().value_counts()
#mflink = mflink.drop_duplicates(subset=['MOTHER_PERSON_ID', 'MOTHER_ENCNTR_ID'], keep=False, inplace=False,
                                #ignore_index=False)

#print('-' * 50)
#print(mflink.shape[0])
#print('-' * 10)
#print(mflink['respiratory'].value_counts())
#print('-' * 10)
#print(mflink['nicu'].value_counts())
#print('-' * 10)
#print(mflink['hypoxia'].value_counts())
#print('-' * 10)
#print(mflink['delayed'].value_counts())
#print('-' * 10)
#print(mflink['enceph'].value_counts())
#print('-' * 50)
# mflink.to_csv('mflink.csv')
# %%


fhrsignals = {}
uasignals = {}

for i in range(len(results)):
    df = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/last_hour_signals_v2/results/' + results[i])
    f = df[['C1 HR0', 'C1 HR1', 'C1 HR2', 'C1 HR3']]  # for fhr
    u = df[['TOCO 0', 'TOCO 1', 'TOCO 2', 'TOCO 3']]  # for UA
    f = f.values.reshape(-1)
    f[f == 0] = np.NaN
    u = u.values.reshape(-1)
    fhrsignals[float(results[i][:8].replace('_', ''))] = f
    uasignals[float(results[i][:8].replace('_', ''))] = u

mflink['minutes'] = [fhrsignals[i].shape[0] / (60 * 4) for i in mflink.index]
mflink = mflink[mflink['minutes'] > 30]

# %%---- plotting sample p -----
p = np.random.choice(mflink.index)
fhr = fhrsignals[p]
ua = uasignals[p]
N = fhr.shape[0]
t = [i / (4. * 60.) for i in range(0, N)]
T = round(max(t))
plt.figure(figsize=(T / 4, 3.5))
plt.subplots_adjust(wspace=0, hspace=0)
ax1 = plt.subplot(2, 1, 1)
ax1.plot(t, fhr, color='red', label='FHR', lw=0.5)
ax1.set_title('CHILD_PERSON_ID = ' + str(p) + ', nicu=' + str(mflink.loc[p, 'nicu'])
              + ', respiratory_distress=' + str(mflink.loc[p, 'respiratory'])
              )
ax1.fill_between(t, 110 * np.ones(N), 160 * np.ones(N), color='gray', alpha=0.2)
ax1.set_ylim([30, 240])
ax1.set_yticks([30, 60, 90, 120, 150, 180, 210, 240])
ax1.yaxis.grid(True, which='minor')
plt.grid(axis='y', lw=0.1)
plt.grid(False, axis='x')
plt.legend()
# -----------
ax2 = plt.subplot(2, 1, 2, sharex=ax1)
ax2.set_ylim([-5, 110])
plt.plot(t, ua, lw=0.4, color='purple', label='UA')
plt.grid(axis='y', lw=0.5)
plt.grid(False, axis='x')
plt.subplots_adjust(wspace=0, hspace=0)
# plt.tight_layout()
plt.legend()
# filename = str(p) + '.pdf'
plt.show()
