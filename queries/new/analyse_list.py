#!/usr/bin/python2.6

# Analyse glideins in the pool
import sys, commands

list=sys.argv[1]
date_s=sys.argv[2]

f = open(list, 'r')
lines=[]
for rline in f.readlines(): lines.append(rline.split('\n')[0].strip().split(' '))
#print len(lines)

c_tot = sum([int(i[0])*int(i[6]) for i in lines]) 
print date_s, "cores total:", c_tot

# List format:
# N_glideins GLIDEIN_CMSSite SlotType State Activity TotalSlotCPUs CPUs Memory GLIDEIN_ToRetire

#Pool size
mcore_t1 = [ line for line in lines if "Partitionable" in line and "T1_" in line[1]]
mcore_t2 = [ line for line in lines if "Partitionable" in line and "T2_" in line[1]]
score_t2 = [ line for line in lines if "Static" in line and "T2_" in line[1]]
score_t3 = [ line for line in lines if "Static" in line and "T3_" in line[1]]

c_m_t1 = sum([int(i[0])*int(i[5]) for i in mcore_t1])
c_m_t2 = sum([int(i[0])*int(i[5]) for i in mcore_t2])
c_s_t2 = sum([int(i[0])*int(i[5]) for i in score_t2])
c_s_t3 = sum([int(i[0])*int(i[5]) for i in score_t3])

print date_s, c_m_t1, c_m_t2, c_s_t2, c_s_t3 

#Pool idle and busy
mcore_busy = [ line for line in lines if "Static" not in line and "Idle" not in line]
mcore_idle = [ line for line in lines if "Static" not in line and "Idle" in line]
static_busy = [ line for line in lines if "Static" in line and "Idle" not in line]
static_idle = [ line for line in lines if "Static" in line and "Idle" in line]

#print len(mcore_busy), len(mcore_idle), len(static_busy), len(static_idle)
c_m_b = sum([int(i[0])*int(i[6]) for i in mcore_busy]) 
c_m_i = sum([int(i[0])*int(i[6]) for i in mcore_idle])
c_s_b = sum([int(i[0])*int(i[6]) for i in static_busy])
c_s_i = sum([int(i[0])*int(i[6]) for i in static_idle])

print date_s, "mcore busy and idle:",c_m_b, c_m_i, ", score busy and idle:", c_s_b, c_s_i

# Check clasification consistency:
print date_s, "mcore tot T1+T2:", c_m_t1+c_m_t2, ", score total T2+T3:",c_s_t2+c_s_t3
print date_s, "mcore tot busy+idle:",c_m_b+c_m_i, ", score total busy+idle:", c_s_b+c_s_i

#classify mcore idle
#HLT
i_hlt = [ line for line in mcore_idle if "T2_CH_CERN_HLT" in line]
#Retiring
i_ret = [ line for line in mcore_idle if "T2_CH_CERN_HLT" not in line and line[8]<date_s]
#Fresh
i_fre = [ line for line in mcore_idle if "T2_CH_CERN_HLT" not in line and line[8]>date_s]

#Claimed idle
i_cla = [ line for line in i_fre if "Claimed" in line]
#Memory
i_mem = [ line for line in i_fre if "Unclaimed" in line and line[7]<2000]
#Unclaimed
i_unc = [ line for line in i_fre if "Unclaimed" in line and line[7]>2000]

#SEPARAR UNCLAIMED DYNAMIC Y UNCLAIMED PARTITIONABLE PARA VER EL EFECTO DE CLAIM WORKLIFE Y CLAIM LEFTOVERS!!

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


