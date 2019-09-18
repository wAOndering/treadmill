path='Y:/Vaissiere/HIGHSPEED/2019-08-28-EMXRUM2-wheel/treadmill'
files = glob.glob(path + '/*.csv', recursive=False)
for i, j in enumerate(files):
	print(i ,j)
	split=files[i].split(os.sep)
	os.rename(files[i], split[0]+'/'+split[1][0:2]+'d6.csv')