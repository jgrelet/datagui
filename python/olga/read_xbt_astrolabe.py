#!/usr/bin/env python
# -*- coding: utf-8 -*-

import netCDF4
from numpy import arange, dtype # array module from http:/
#from matplotlib.toolkits.basemap import Basemap, shiftgrid
from mpl_toolkits.basemap import Basemap, shiftgrid
from pylab import *
import matplotlib.colors as colors
from optparse import OptionParser
import sys, os, locale
import datetime
import glob
import math, numpy, re, time 
from datetime import datetime as real_datetime 
from datetime import tzinfo, timedelta 

import matplotlib.dates as mdates
import time, calendar 
import matplotlib.cbook as cbook
from matplotlib.dates import YearLocator,DayLocator,MonthLocator,DateFormatter 
from matplotlib.ticker import FuncFormatter, MultipleLocator, FormatStrFormatter
import matplotlib.text as text
import matplotlib.lines as mpllines
from netcdftime import utime
import netcdftime
from mpl_toolkits.axes_grid.inset_locator import inset_axes

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from mpl_toolkits.basemap import Basemap
from matplotlib.patches import CirclePolygon 
from matplotlib.collections import PatchCollection

import os
import math
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from mpl_toolkits.basemap import Basemap
from matplotlib.patches import CirclePolygon 
from matplotlib.collections import PatchCollection

"""
PLOT XBT PROFILES
"""
##########################################################################
# Globals
##########################################################################

lonmin=141.0
lonmax=150.0
latmin=-68
latmax=-40

############################################# 
# MAIN
#############################################
def main():

    '''
    Reading XBT DATA (NETCDF FILE)

    '''
    list_files=[]
    for drop in xrange(93):
        drop=drop+1
        if drop < 10:
            drop2='0'+str(drop)
        else:
            drop2=str(drop)
        xbt_file='../data_XBT/LA1301A/drop0'+drop2+'.nc'
    
        print list_files
        dict_data_xbt= {}.fromkeys( ['longitude','latitude','depth','temperature'] )
        data=read_xbt_data(xbt_file,dict_data_xbt)
        xbt_outputfile='../figures_XBT/xbt_number_'+drop2+'.jpg'
        plot_xbt(data,xbt_outputfile,str(drop),'no')

############################################ 
# FONCTIONS 
############################################

def read_xbt_data(filename,dict_data):
    ''' 
    Reading all key in data file
    INPUT: 1) Filename
           2) dictionary with all the keys used          
    '''
    print filename
    nc2=netCDF4.Dataset(filename,'r')
    data = {}.fromkeys(dict_data)
    for key in data.keys():
            data[key] = (np.array(nc2.variables[key][:]))
    nc2.close()

    return data


def plot_xbt(data,outputname,number,show_figure):
    '''
    PLOT XBT profile + map 
    '''

    # PLOT XBT PROFILE
    taille_map=(6,8)
    fig1=figure(facecolor='w',figsize=taille_map)
    plt.subplots_adjust(wspace=0.25,bottom=0.08,left=0.15,right=0.93,top=0.91,hspace=0.2)
    ax=subplot(1,1,1)
    majorLocator   = MultipleLocator(4.0)
    majorFormatter = FormatStrFormatter('%1.1f')
    minorLocator   = MultipleLocator(1.0)

    ax.plot(data['temperature'][0,:,0,0],data['depth'],color='r',label='SST',linewidth=1.5,zorder=1)
    ylim([0,max(data['depth'])+50])
    ax.xaxis.set_minor_locator(minorLocator)
    ax.xaxis.set_major_locator(majorLocator)
    ax.xaxis.set_major_formatter(majorFormatter)
    ylabel('Depth')
    xlabel('Temperature') 
    ylim([0,max(data['depth'])+50])
    xlim([round(min(data['temperature'][0,:,0,0]),0)-1,20])
    grid('on')
    plt.gca().invert_yaxis()

    titlename= 'XBT ' + number + ': [' + str(round(data['latitude'][0],1)) + u'\N{DEGREE SIGN}N, ' + str(abs(round(data['longitude'][0],1)))+  u'\N{DEGREE SIGN}W' +']'
    suptitle(titlename)

    a = axes([0.72, 0.77, .2, .2])
    # PLOT MAP POSITION OF XBT LOCATION
    map1 = Basemap(projection='cyl',llcrnrlat=latmin,urcrnrlat=latmax,llcrnrlon=lonmin,urcrnrlon=lonmax,resolution='l')
    map1.plot(data['longitude'],data['latitude'],marker='o',color='red',markeredgecolor='red')
    meridians_range=np.arange(-180,360,7)
    parallels_range=np.arange(-80,80,15)

    map1.drawcoastlines()
    map1.fillcontinents(color='grey')
    map1.drawmeridians(meridians_range, labels=[0,0,0,1],labelstyle=None)
    map1.drawparallels(parallels_range, labels=[1,0,0,0],labelstyle=None) 
    a.set_aspect('auto')
    for o in fig1.findobj(matplotlib.text.Text):
        o.set_size('16') 

    if show_figure=='yes':
        plt.show()
    else:    
        print 'saving figure ', outputname
        savefig(outputname, dpi=200 ) 

if __name__ == '__main__':
    main()


