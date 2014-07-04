#!/usr/bin/env python
# -*- coding: utf-8 -*-

from numpy import arange, dtype # array module from http:/
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
from mpl_toolkits.axes_grid.inset_locator import inset_axes
from scipy import stats
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.cm as cm


##########################################################################
# Globals
##########################################################################

day   = mdates.HourLocator(interval=3)  # label x axes each 3 houres
day2   = mdates.HourLocator(interval=1) # small tick each hour 
formatter = DateFormatter('%d/%m %HH')

############################################# 
# MAIN
#############################################

def main():

    '''
    Reading TSG DATA (ASCII FILE)

    '''
    for d in xrange(1):
        day = d + 8
        if day > 31:
            day = day - 31
            date='0'+str(day)+'042013'
            month='04'
            day='0'+str(day)
        else:
            date=str(day)+'032013'
            month='03'

        outputfile='datos/TSG-POS-process/Sarmiento_2013'+str(month) + str(day)+'.csv'
        print 'reading file', outputfile
        data=reading_csv_data(outputfile)

        print 'min max SSS: ', min(data['SSS']),max(data['SSS'])
        outputname6='figures/series_temporales_por_dia/SSS_SST_lat_lon/TSG-'+date+'-SSS_SST_lat_lon.png'
        plot_SST_SSS_versus_time(data,outputname6)

 
############################################ 
# FONCTIONS 
############################################

def reading_csv_data(filename):
    """"
    Reading CSV FILE of TSG SHIP DATA 
    """
    data_out = {}.fromkeys( ['time','lat','lon','SSS','SST','C','sigmat','fluor'] ) 
    for key in data_out.keys():
        data_out[key]=[]
    FileIn = open(filename,'rb')
    titles = FileIn.next().strip().split(';')
    for row in FileIn:
        values = row.strip().split(';' )
        data = dict(zip(titles, values))
        for key in data_out.keys():
            if key != 'time':
                data_out[key].append(np.float(data[key]))
            else:
                data_out[key].append(datetime.datetime.strptime(data[key],'%Y-%m-%d %H:%M:%S'))         
    return data_out
  

def plot_SST_SSS_versus_time(data,outputname):
    '''
    PLOT SST SSS LAT LON values in the same axes 
    '''

    fig1=figure(facecolor='w',figsize=(17,5))
    plt.subplots_adjust(wspace=0.1,bottom=0.14,left=0.08,right=0.82,top=0.90,hspace=0.2)

    ax=plt.gca()
    from scipy import stats
    plot(data['time'],data['SSS'],color='k',linewidth=1.2)
    ylabel('SSS')
    grid(True)
    fig1.autofmt_xdate()

    ax2=ax.twinx()
    ax2.plot(data['time'],data['SST'],color='b',linewidth=1.2)
    ylabel('SST',color='blue')

    ax3=ax.twinx()
    ax3.plot(data['time'],data['lat'],color='r',linewidth=1.2)

    ax4=ax.twinx()
    ax4.plot(data['time'],data['lon'],color='orange',linewidth=1.2)    


    # Move the last y-axis spine over to the right by 20% of the width of the axes
    ax3.spines['right'].set_position(('axes', 1.075))
    ax3.set_ylabel('lat',color='red')
    ax4.spines['right'].set_position(('axes', 1.155))   

    # To make the border of the right-most axis visible, we need to turn the frame
    # on. This hides the other plots, however, so we need to turn its fill off.
    ax3.set_frame_on(True)
    ax3.patch.set_visible(False)
    ax4.set_ylabel('lon',color='orange')
    ax4.set_frame_on(True)
    ax4.patch.set_visible(False)

    for tl in ax2.get_yticklabels(): # write axes values in the same color than data 
        tl.set_color('b')
    for tl in ax3.get_yticklabels(): 
        tl.set_color('r')
    for tl in ax4.get_yticklabels(): 
        tl.set_color('orange')
    fig1.autofmt_xdate()

    # print correlation between SSS and SST 
    corr_data1 = stats.pearsonr(data['SSS'],data['SST'])
    print corr_data1
    
    for o in fig1.findobj(matplotlib.text.Text):
        o.set_size('15') 

    # Labels ticks for dates 
    ax.xaxis.set_major_locator(day)
    ax.xaxis.set_minor_locator(day2)
    ax.xaxis.set_major_formatter(formatter)

    ax2.xaxis.set_major_locator(day)
    ax2.xaxis.set_minor_locator(day2)
    ax2.xaxis.set_major_formatter(formatter)

    print min(data['time']), max(data['time'])
    xlim([min(data['time']),max(data['time'])])
    fig1.autofmt_xdate()
    title('SSS - SST TSG',weight='bold',fontsize=15)
    simpleaxis(ax)
    savefig(outputname,dpi=200)

def simpleaxis(ax):
    '''
    Fonction pour mettre les ticks a l exterieur et plus gros
    '''

    ax.get_xaxis().tick_bottom()
    ax.get_yaxis().tick_left()

    linesx = ax.get_xticklines()
    labels = ax.get_xticklabels()
    linesy = ax.get_yticklines()
    labels2 = ax.get_yticklabels()

    for line in linesx:  
        line.set_marker(mpllines.TICKDOWN)
        line.set_markeredgewidth(2)
    for label in labels:
        label.set_y(-0.025)

    for label in labels2:
        label.set_x(-0.015)
    for line in linesy:  
        line.set_marker(mpllines.TICKLEFT)
        line.set_markeredgewidth(2)


if __name__ == '__main__':
    main()
