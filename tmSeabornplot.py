import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd


outpath='/run/user/1000/gvfs/smb-share:server=ishtar,share=millerrumbaughlab/Vaissiere/SyngapKO 9-19-19 shock/SyngapKO 9-19-19 shock teraterm/output - preS10s - postS5s/'


# to plot main shock
dt=pd.read_csv('/run/user/1000/gvfs/smb-share:server=ishtar,share=millerrumbaughlab/Vaissiere/SyngapKO 9-19-19 shock/SyngapKO 9-19-19 shock teraterm/expinfo/summaryDetails.csv')
dt.motionCat.unique()
dt=dt.loc[dt.motionCat.isin(['B  ','F  '])]
# test=dt[(dt['sID']==628) & (dt['habDay']==1) & (dt['motionCat']=='F  ')]
# convert the data to a timeseries and set as index
dt.timeFromStart=pd.to_timedelta(dt.timeFromStart, unit='S')
dt=dt.set_index(dt.timeFromStart)
# groupby and resampling see doc https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.core.groupby.DataFrameGroupBy.resample.html
dtplotSummary=dt.groupby(['motionCat','sID','habDay', 'Genotype']).resample('60S', closed='left', label='left').sum()
dtplotSummary=dtplotSummary['distanceCat']
dtplotSummary=dtplotSummary.reset_index()
subCat=dtplotSummary.groupby(['motionCat','sID','habDay']).cumcount() # create subgroups and subcategory
dtplotSummary['subCatBins']=subCat

cumData=dtplotSummary.groupby(['motionCat','sID','habDay', 'Genotype','subCatBins']).sum().groupby(['motionCat','sID','habDay', 'Genotype']).cumsum()['distanceCat']
cumData=cumData.reset_index()
dtplotSummary['cumData']=cumData['distanceCat']

# sns.lineplot(x='timeFromStart', y='distanceCat', data=dt, hue='Genotype')
fig=sns.relplot(x='subCatBins', y='cumData', hue='Genotype', data=dtplotSummary, col='habDay', row='motionCat', kind='line', palette=['r','b'])
plt.show(block=False)
fig.savefig(outpath+'summaryBinscum.pdf', bbox_inches='tight', transparent=False, dpi=300)



# to plot the 

dtt=pd.read_csv('/run/user/1000/gvfs/smb-share:server=ishtar,share=millerrumbaughlab/Vaissiere/SyngapKO 9-19-19 shock/SyngapKO 9-19-19 shock teraterm/output - preS10s - postS5s/MainSummary_pre10_post5.csv')
# fig= plt.figure(figsize=(4.08,2.29))
fig=sns.relplot(x='shock', y='distanceWin', data=dtt, col='shockWin', hue='Genotype', kind='line', palette=['r','b'])
# sns.relplot(x='shock', y='speedSum', data=dtt, col='shockWin', hue='Genotype', kind='line', palette=['r','b'])
# sns.relplot(x='shock', y='speedAvg', data=dtt, col='shockWin', hue='Genotype', kind='line', palette=['r','b'])
plt.show(block=False)
fig.savefig(outpath+'summaryShock.pdf', bbox_inches='tight', transparent=False, dpi=300)



