#!/usr/bin/python2.6

# Analyse glideins in the pool
import sys, commands
date_s=sys.argv[1]

f = open('test_list', 'r')
lines=[]
for rline in f.readlines(): lines.append(rline.split('\n')[0].strip().split(' '))
#print len(lines)

c_tot = sum([int(i[0])*int(i[6]) for i in lines]) 
print "cores total:", c_tot

# List format:
# N_glideins GLIDEIN_CMSSite SlotType State Activity TotalSlotCPUs CPUs Memory GLIDEIN_ToRetire

mcore_busy = [ line for line in lines if "Static" not in line and "Idle" not in line]
mcore_idle = [ line for line in lines if "Static" not in line and "Idle" in line]
static_busy = [ line for line in lines if "Static" in line and "Idle" not in line]
static_idle = [ line for line in lines if "Static" in line and "Idle" in line]

#print len(mcore_busy), len(mcore_idle), len(static_busy), len(static_idle)

#Count cores per category and total
c_m_b = sum([int(i[0])*int(i[6]) for i in mcore_busy]) 
c_m_i = sum([int(i[0])*int(i[6]) for i in mcore_idle])
c_s_b = sum([int(i[0])*int(i[6]) for i in static_busy])
c_s_i = sum([int(i[0])*int(i[6]) for i in static_idle])

c_m_t = c_m_b+c_m_i
c_s_t = c_s_b+c_s_i

print "mcore tot:",c_m_t, ", score total:", c_s_t, ", total", c_m_t+c_s_t
print "mcore busy and idle:",c_m_b, c_m_i, ", score busy and idle:", c_s_b, c_s_i

#classify mcore idle
i_hlt = [ line for line in mcore_idle if "T2_CH_CERN_HLT" in line]
i_ret = [ line for line in mcore_idle if "T2_CH_CERN_HLT" not in line and line[8]<date_s]
i_fre = [ line for line in mcore_idle if "T2_CH_CERN_HLT" not in line and line[8]>date_s]

i_cla = [ line for line in i_fre if "Claimed" in line]
i_mem = [ line for line in i_fre if "Unclaimed" in line and line[7]<2000]
i_unc = [ line for line in i_fre if "Unclaimed" in line and line[7]>2000]

#print len(mcore_idle)
#print len(i_hlt)+len(i_ret)+len(i_cla)+len(i_mem)+len(i_unc)
c_i_hlt = sum([int(i[0])*int(i[6]) for i in i_hlt])
c_i_ret = sum([int(i[0])*int(i[6]) for i in i_ret])
c_i_cla = sum([int(i[0])*int(i[6]) for i in i_cla])
c_i_mem = sum([int(i[0])*int(i[6]) for i in i_mem])
c_i_unc = sum([int(i[0])*int(i[6]) for i in i_unc])

print c_m_i
print "date", date_s
print "HLT:",c_i_hlt,"retire:",c_i_ret,"claimed idle:",c_i_cla,"memory:",c_i_mem,"other unclaimed:",c_i_unc


