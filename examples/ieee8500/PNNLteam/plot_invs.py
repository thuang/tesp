# Copyright (C) 2018 Battelle Memorial Institute
# file: process_gld.py; custom for the IEEE 8500-node circuit
import json;
import sys;
import numpy as np;
import matplotlib as mpl;
import matplotlib.pyplot as plt;

# first, read and print a dictionary of all the monitored GridLAB-D objects
lp = open (sys.argv[1] + "_glm_dict.json").read()
dict = json.loads(lp)
inv_keys = list(dict['inverters'].keys())
inv_keys.sort()
mtr_keys = list(dict['billingmeters'].keys())
mtr_keys.sort()
xfMVA = dict['transformer_MVA']
matBus = dict['matpower_id']

# parse the substation metrics file first; there should just be one entity per time sample
# each metrics file should have matching time points
lp_i = open ("inverter_" + sys.argv[1] + "_metrics.json").read()
lst_i = json.loads(lp_i)
print ("\nMetrics data starting", lst_i['StartTime'])

# make a sorted list of the sample times in hours
lst_i.pop('StartTime')
meta_i = lst_i.pop('Metadata')
times = list(map(int,list(lst_i.keys())))
times.sort()
print ("There are", len (times), "sample times at", times[1] - times[0], "second intervals")
hrs = np.array(times, dtype=np.float)
denom = 3600.0
hrs /= denom
time_key = str(times[0])

# parse the metadata for things of specific interest
print("\nInverter Metadata for", len(lst_i[time_key]), "objects")
for key, val in meta_i.items():
  print (key, val['index'], val['units'])
  if key == 'real_power_avg':
    INV_P_AVG_IDX = val['index']
    INV_P_AVG_UNITS = val['units']
  elif key == 'reactive_power_avg':
    INV_Q_AVG_IDX = val['index']
    INV_Q_AVG_UNITS = val['units']

# create a NumPy array of all metrics
data_i = np.empty(shape=(len(inv_keys), len(times), len(lst_i[time_key][inv_keys[0]])), dtype=np.float)
#print ("\nConstructed", data_s.shape, "NumPy array for Substations")
j = 0
for key in inv_keys:
  i = 0
  for t in times:
    ary = lst_i[str(t)][inv_keys[j]]
    data_i[j, i,:] = ary
    i = i + 1
  j = j + 1

# Billing Meters 
lp_m = open ("billing_meter_" + sys.argv[1] + "_metrics.json").read()
lst_m = json.loads(lp_m)
lst_m.pop('StartTime')
meta_m = lst_m.pop('Metadata')
print("\nBilling Meter Metadata for", len(lst_m[time_key]), "objects")
for key, val in meta_m.items():
	print (key, val['index'], val['units'])
	if key == 'voltage_max':
		MTR_VOLT_MAX_IDX = val['index']
		MTR_VOLT_MAX_UNITS = val['units']
	elif key == 'voltage_min':
		MTR_VOLT_MIN_IDX = val['index']
		MTR_VOLT_MIN_UNITS = val['units']
	elif key == 'voltage_avg':
		MTR_VOLT_AVG_IDX = val['index']
		MTR_VOLT_AVG_UNITS = val['units']

data_m = np.empty(shape=(len(mtr_keys), len(times), len(lst_m[time_key][mtr_keys[0]])), dtype=np.float)
vmax = 0.0
jmax = 0
imax = 0
keymax = ''
j = 0
for key in mtr_keys:
	i = 0
	for t in times:
		val = lst_m[str(t)][mtr_keys[j]][MTR_VOLT_AVG_IDX]
		data_m[j, i] = val
		if val > vmax:
			vmax = val
			keymax = key
			jmax = j
			imax = i
		i = i + 1
	j = j + 1

invmax = ''
invidx = 0
i = 0
print ('max voltage', vmax, 'at meter', keymax, jmax, 'time', hrs[imax])

# look for the meter with most counts over 126
i = 0
mtridx = jmax
countmax = 0
for key in mtr_keys:
	val = (data_m[i,:] > 126.0).sum()
	if val > countmax:
		countmax = val
		keymax = key
		mtridx = i
	i = i + 1
print ('meter with', countmax, 'points above 126 is', keymax, mtridx)

i = 0
for key in inv_keys:
	if dict['inverters'][key]['billingmeter_id'] == keymax:
		if dict['inverters'][key]['resource'] == 'solar':
			invmax = key
			invidx = i
	i = i + 1
print ('inverter is', invmax, invidx)

# display a plot
fig, ax = plt.subplots(2, 1, sharex = 'col')
tmin = 0.0
tmax = 24.0
xticks = [0,4,8,12,16,20,24]
#----------------------------------------------------------
#i = 0                                                     
#for key in inv_keys:                                      
#  ax[0].plot(hrs, data_i[i,:,INV_P_AVG_IDX], color="blue")
#  ax[1].plot(hrs, data_i[i,:,INV_Q_AVG_IDX], color="red") 
#  i = i + 1                                               
#ax[0].set_ylabel(INV_P_AVG_UNITS)                         
#ax[1].set_ylabel(INV_Q_AVG_UNITS)                         
#ax[1].set_xlabel("Hours")                                 
#ax[0].set_title ("Power at all Inverters")                
#----------------------------------------------------------

ax[0].set_title ('Inverter ' + invmax)                
ax[0].plot(hrs, 0.001 * data_i[invidx,:,INV_P_AVG_IDX], color="blue", label='P')
ax[0].plot(hrs, 0.001 * data_i[invidx,:,INV_Q_AVG_IDX], color="green", label='Q')
ax[0].set_xlim(tmin,tmax)
ax[0].set_xticks(xticks)
ax[0].legend(loc='best')
ax[0].set_ylabel('KVA')                         
ax[1].plot(hrs, (1.0 / 120.0) * data_m[mtridx,:], color="red") 
ax[1].set_xlim(tmin,tmax)
ax[1].set_xticks(xticks)
ax[1].set_ylabel('Voltage [pu]')                         
ax[1].set_xlabel('Hours')                                 

plt.show()


