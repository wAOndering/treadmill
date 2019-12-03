import glob
import pandas as pd
import matplotlib.pyplot as plt

path='/run/user/1000/gvfs/smb-share:server=ishtar,share=millerrumbaughlab/Vaissiere/HIGHSPEED/2019-08-28-EMXRUM2-wheel/treadmill' 
files=glob.glob(path+'/*clean.txt')

for i, j in enumerate(files):
	print(i,j)

dt=pd.read_csv(j)

dt.index=pd.to_datetime(dt.timeFromStart)
fwd=dt[dt.motionCat=="F  "]
bwd=dt[dt.motionCat=="B  "]
fwd.index = pd.to_datetime(fwd.timeFromStart)
bwd.index = pd.to_datetime(bwd.timeFromStart)
plt.plot(fwd.speed)
plt.plot(-bwd.speed)
plt.plot(fwd.distance)
plt.plot(-bwd.distance)
# plt.plot(fwd.speed)

plt.scatter(fwd.index, fwd.distStep)
plt.scatter(bwd.index, -bwd.distStep)

plt.show(block=False)
type(dt)


