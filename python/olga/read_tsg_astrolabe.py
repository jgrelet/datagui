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

##########################################################################
# Globals
##########################################################################
lonmin=139.0
lonmax=149.0
latmin=-68
latmax=-40

############################################# 
# MAIN
#############################################
def main():

    '''
    Reading TSG DATA (ASCII FILE)

    '''
    list_files=[]
    # READING ALL DATA FROM 3 Dec to 3 January
    for d in xrange(32):
        day = d + 3
        if day < 10:
            date='2013120'+str(day)
        elif day > 31:
            date='2014010'+str(day-31)
        else:
            date='201312'+str(day)
        list_files.append('../data_TSG/'+str(date)+'.dat')

    print 'list of files', list_files
    
    # READING SST AND SSS
    data=reading_csv_data_list(list_files)

    print 'min max SSS: ', min(data['SSS']),max(data['SSS'])
    print 'min max SST: ', min(data['SST']),max(data['SST'])

    # READING GPS POSITIONS
    gpspos=reading_csv_pos(list_files)

    # PLOT GLOBAL MAP SSS
    cmin=33.0 # MIN color
    cmax=35.4 # MAX color
    outputname='../figures_TSG/TSG-all-map-SSS.png'
    plot_positions_var(gpspos,data,outputname,cmin,cmax,'SSS')

    # PLOT GLOBAL MAP SST
    outputname='../figures_TSG/TSG-all-map-SST.png'
    cmin=0 # MIN color
    cmax=15 # MAX color
    plot_positions_var(gpspos,data,outputname,cmin,cmax,'SST')

    # PLOT TIME SERIES
    outputname='../figures_TSG/TSG-all-SSS_lat_SST-0312_0812.png'
    SSSrange=[32,36]
    SSTrange=[-2,15]
  #  date_min='21-12-2013 00:00:00'
  #  date_max='02-01-2014 21:00:00'
    date_min='03-12-2013 12:00:00'
    date_max='08-12-2013 02:00:00'

    # yes for showing figure in the screen, no: to save figure in png
    plot_allvar_versus_time(data,outputname,SSSrange,SSTrange,date_min,date_max,'no')

############################################ 
# FONCTIONS 
############################################

def reading_csv_pos(filenames):
    """"
    Lecture GPS file
    """
    #print filenames
    data_out = {}.fromkeys( ['GPS Latitude','GPS Longitude','time'] ) 
    for key in data_out.keys():
        data_out[key]=[]

    for i in xrange(len(filenames)):
        FileIn = open(filenames[i],'rb')
        titles = FileIn.next().strip().split('	')
     #   print titles
        for row in FileIn:
            values = row.strip().split('	')
            data = dict(zip(titles, values))
            for key in data_out.keys():
                if key != 'GPS date' and key!='GPS time' and key!='Sys time' and key!='time':
                    data_out[key].append(np.float(data[key]))
            data_out['time'].append(datetime.datetime.strptime(data['GPS date']+' ' +data['GPS time'],'%d/%m/%y %H:%M:%S')) 

    data_out['lon']=data_out['GPS Longitude']
    data_out['lat']=data_out['GPS Latitude']
    return data_out

def reading_csv_data_list(filenames):
    """"
    Lecture SST and SSS file 
    """
    data_out = {}.fromkeys( ['GPS Latitude','GPS Longitude','T Remote','Salinity','time','Pump Pressure','Flowmeter'] ) 
    for key in data_out.keys():
        data_out[key]=[]

    for i in xrange(len(filenames)):
        FileIn = open(filenames[i],'rb')
        titles = FileIn.next().strip().split('	')
        for row in FileIn:
            values = row.strip().split('	')
            data = dict(zip(titles, values))
            for key in data_out.keys():
                if np.float(data['Pump Pressure']) > 0.7 and np.float(data['Flowmeter']) > 20:
                    if np.float(data['T Remote'])<30 and np.float(data['T Remote'])>-10:
                        if key != 'GPS date' and key!='GPS time' and key!='Sys time' and key!='time':
                            data_out[key].append(np.float(data[key]))
                        elif key == 'time':                   
                            data_out['time'].append(datetime.datetime.strptime(data['GPS date']+' ' +data['GPS time'],'%d/%m/%y %H:%M:%S'))

    data_out['SST']=data_out['T Remote'] 
    data_out['SSS']=data_out['Salinity']  
    data_out['lon']=data_out['GPS Longitude']
    data_out['lat']=data_out['GPS Latitude']

    return data_out

def plot_positions_var(gpsdata,data,outputname,cmin,cmax,var):
    '''
    PLOT MAP WITH SSS OR SST 
    '''
    fig1=figure(facecolor='w',figsize=(9,10))

    ax=plt.gca()
    map1 = Basemap(llcrnrlon=lonmin,urcrnrlon=lonmax,llcrnrlat=latmin, urcrnrlat=latmax, resolution='h',projection='cyl')
    meridians_range=np.arange(-180,181,4.0)
    parallels_range=np.arange(-90,91,5.0)

    t_lab=np.arange(cmin,cmax,0.4)
    t=np.arange(cmin,cmax,0.05)

    color_under=([0,0,0.1])
    color_over=([0.4,0.0,0.0])
    map1.drawmeridians(meridians_range,labels=[1,0,0,1])
    map1.drawparallels(parallels_range,labels=[1,0,0,1])
    map1.drawcoastlines()

    map1.fillcontinents(color=[0.8,0.8,0.8])
    map1.plot(gpsdata['lon'],gpsdata['lat'],color='black')

    pc=map1.scatter(data['lon'], data['lat'], c= data[var], s=20.0, norm = colors.BoundaryNorm(t,ncolors=256, clip = False),edgecolor='none')
    cbar=colorbar(pc, pad=0.1 ,orientation = 'vertical', extend = 'both' ) 
    cbar.set_label(var) 

    pc.cmap.set_over(color_over)
    pc.cmap.set_under(color_under)

    #### PLOT quelques dates de passage du bateau - 
    date1='04-12-2013'
    date2='05-12-2013'
    date3='06-12-2013'
    date4='07-12-2013'
    date5='08-12-2013'
    date6='10-12-2013'
    date7='30-12-2013'
    date8='21-12-2013'
    date9='01-01-2014'
    date10='02-01-2014'
    date11='31-12-2013'

    plot_time1=0
    plot_time2=0
    plot_time3=0
    plot_time4=0
    plot_time5=0
    plot_time6=0
    plot_time7=0
    plot_time8=0
    plot_time9=0
    plot_time10=0
    plot_time11=0

    for l in xrange(len(gpsdata['time'])):
        if gpsdata['time'][l]== datetime.datetime.strptime(date6,'%d-%m-%Y'):
            if plot_time6==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.15,gpsdata['lat'][l],date6,color='black')
                plot_time6=1
   
        if gpsdata['time'][l]== datetime.datetime.strptime(date7,'%d-%m-%Y'):
            if plot_time7==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l],gpsdata['lat'][l],date7,color='black')
                plot_time7=1   

        if gpsdata['time'][l]== datetime.datetime.strptime(date8,'%d-%m-%Y'):
            if plot_time8==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.1,gpsdata['lat'][l],date8,color='black')
                plot_time8=1

        if gpsdata['time'][l]== datetime.datetime.strptime(date9,'%d-%m-%Y'):
            if plot_time9==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.1,gpsdata['lat'][l],date9,color='black')
                plot_time9=1
        if gpsdata['time'][l]== datetime.datetime.strptime(date11,'%d-%m-%Y'):
            if plot_time11==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.15,gpsdata['lat'][l],date11,color='black')
                plot_time11=1                  
        if gpsdata['time'][l]== datetime.datetime.strptime(date7,'%d-%m-%Y'):
            if plot_time7==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.1,gpsdata['lat'][l],date7,color='black')
                plot_time7=1   
        if gpsdata['time'][l]== datetime.datetime.strptime(date10,'%d-%m-%Y'):
            if plot_time10==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.1,gpsdata['lat'][l]+0.1,date10,color='black')
                plot_time10=1
        if gpsdata['time'][l]== datetime.datetime.strptime(date1,'%d-%m-%Y'): 
            if plot_time1==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.2,gpsdata['lat'][l],date1,color='black')
                plot_time1=1
        if gpsdata['time'][l]== datetime.datetime.strptime(date2,'%d-%m-%Y'):
            if plot_time2==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.2,gpsdata['lat'][l],date2,color='black')
                plot_time2=1
        if gpsdata['time'][l]== datetime.datetime.strptime(date3,'%d-%m-%Y'):
            if plot_time3==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.1,gpsdata['lat'][l],date3,color='black')
                plot_time3=1
        if gpsdata['time'][l]== datetime.datetime.strptime(date4,'%d-%m-%Y'):
            if plot_time4==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.1,gpsdata['lat'][l],date4,color='black')
                plot_time4=1 
        if gpsdata['time'][l]== datetime.datetime.strptime(date5,'%d-%m-%Y'):
            if plot_time5==0:
                map1.plot(gpsdata['lon'][l],gpsdata['lat'][l],'*',color='black')
                ax.text(gpsdata['lon'][l]+0.15,gpsdata['lat'][l],date5,color='black')
                plot_time5=1   

    #### fin PLOT 

    ax.set_aspect('auto')
    for o in fig1.findobj(matplotlib.text.Text):
        o.set_size('15') 
  
    title(var + ' - TSG data - Astrolabe December 2013',weight='bold',fontsize=15)
    savefig(outputname,dpi=500)

def plot_allvar_versus_time(data,outputname,SSSrange,SSTrange,datemin,datemax,show_figure):
    """
    PLOT SST,SSS, lat versus time
    """
    fig1=figure(facecolor='w',figsize=(18,6))
    plt.subplots_adjust(wspace=0.1,bottom=0.14,left=0.08,right=0.87,top=0.90,hspace=0.2)

    ax1=plt.gca()
    ax1.plot(data['time'],data['SSS'],'.',color='k',markersize=1.2)
    #ylim([32,36])
    ylim(SSSrange)
    ylabel('SSS')
    grid(True)

    fig1.autofmt_xdate()
    ax2=ax1.twinx()
    ax2.plot(data['time'],data['SST'],'.',color='b',markersize=1.2)
    ylabel('SST',color='blue')

   # ylim([-2,15])
    ylim(SSTrange)
    ax3=ax1.twinx()
    ax3.plot(data['time'],data['lat'],color='r',linewidth=1.2)

    ax4=ax1.twinx()
    ax4.plot(data['time'],data['lon'],color='orange',linewidth=1.2)    

    # Move the last y-axis spine over to the right by 20% of the width of the axes
    ax3.spines['right'].set_position(('axes', 1.05))
    ax3.set_ylabel('lat',color='red')
    ax4.spines['right'].set_position(('axes', 1.10))   
    # To make the border of the right-most axis visible, we need to turn the frame
    # on. This hides the other plots, however, so we need to turn its fill off.
    ax3.set_frame_on(True)
    ax3.patch.set_visible(False)
    ax4.set_ylabel('lon',color='orange')
    ax4.set_frame_on(True)
    ax4.patch.set_visible(False)
    for tl in ax2.get_yticklabels(): # permet d'ecrire les valeurs sur l'axe de la meme couleur que la courbe
        tl.set_color('b')
    for tl in ax3.get_yticklabels(): # permet d'ecrire les valeurs sur l'axe de la meme couleur que la courbe
        tl.set_color('r')
    for tl in ax4.get_yticklabels(): # permet d'ecrire les valeurs sur l'axe de la meme couleur que la courbe
        tl.set_color('orange')
    fig1.autofmt_xdate()


    from scipy import stats
    corr_data1 = stats.pearsonr(data['SSS'],data['SST'])
    print 'SST-SSS Correlation', corr_data1

    for o in fig1.findobj(matplotlib.text.Text):
        o.set_size('15') 

    day   = mdates.DayLocator(interval=1) 
    day2   = mdates.HourLocator(interval=6) 
    formatter = DateFormatter('%d/%m')

   # day   = mdates.HourLocator(interval=6) 
   # day2   = mdates.HourLocator(interval=1) 
  #  locale.setlocale(locale.LC_TIME,'en_US')
  #  formatter = DateFormatter('%d/%m %Hh')

    # Labels ticks pour les dates
    ax1.xaxis.set_major_locator(day)
    ax1.xaxis.set_minor_locator(day2)
    ax1.xaxis.set_major_formatter(formatter)
    ax2.xaxis.set_major_locator(day)
    ax2.xaxis.set_minor_locator(day2)
    ax2.xaxis.set_major_formatter(formatter)

    time_min = datetime.datetime.strptime(datemin,'%d-%m-%Y %H:%M:%S')
    time_max = datetime.datetime.strptime(datemax,'%d-%m-%Y %H:%M:%S')
    xlim([time_min,time_max])
    #xlim([min(data['time']),time_max])
 #   xlim([min(data['time']),max(data['time'])])
    fig1.autofmt_xdate()
    title('SSS - SST TSG',weight='bold',fontsize=15)
    simpleaxis(ax1)

    if show_figure=='yes':
        plt.show()
    else:    
        print 'saving figure ', outputname
        savefig(outputname, dpi=200 ) 


def simpleaxis(ax):
    '''
    Fonction pour mettre les ticks a l exterieur et plus gros
    '''
  #  ax.spines['top'].set_visible(False)
  #  ax.spines['right'].set_visible(False)
    ax.get_xaxis().tick_bottom()
    ax.get_yaxis().tick_left()
  #  mpl.interactive(True)
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


