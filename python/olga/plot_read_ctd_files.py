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

################################################################################################
# MAIN 
################################################################################################

def main():
    show_figure='yes' # si tu veux la visualiser 'no', si tu veux sauver l'image en png

    # FICHIER CTD  
    number_ctd=sys.argv[1] # numero de ctd du fichier
    ctd_file= 'datos/ctd-'+number_ctd+'-coriolis.cnv'
 
    # MODIF ctd file
    # name 0 = prDM: Pressure, Digiquartz [db]
    # name 1 = latitude: Latitude [deg]
    # name 2 = longitude: Longitude [deg]
    # name 3 = timeJ: Julian Days
    # name 4 = t090C: Temperature [ITS-90, deg C]
    # name 5 = c0S/m: Conductivity [S/m]
    # name 6 = sal00: Salinity, Practical [PSU]
    # name 7 = flag: flag
    
    # Recherche line fichier ou il y a *END* (fin des entetes) 
    string0="grep -n *END* "+ ctd_file + "> line_to_cut "
    file_line=str(os.system(string0))
    line_to_cut=read_line('line_to_cut')[2:5]  

    # supprime toutes les entetes de la ligne 1 a la ligne avec *END*
    string1= "sed '1,"+line_to_cut +"d' < "+ ctd_file + "> data_v00_modif2"
    os.system(string1)
    # remplacer les multiples espaces du fichier par un seul espace 
    string1= "tr -s ' ' <  data_v00_modif2 > data_v00_modif3"
    os.system(string1)
    # adding titles to file 
    string2= """awk 'NR == 1 { print "n prDM lat lon timeJ SST C SSS flag" } { print }' data_v00_modif3 > data_v00_modif4"""
    os.system(string2)
    # remplace espace par ;
    string3= """tr " " ";" <  data_v00_modif4 > data_v00_modif"""
    os.system(string3)
    # supprime fichier temporaires
    os.system("rm data_v00_modif2 data_v00_modif3 data_v00_modif4 line_to_cut")
    drifter_file2= 'data_v00_modif'

    # Lecture CTD 
    data_ctd=read_ctd_file(drifter_file2,lonmin,lonmax,latmin,latmax)
    print len(data_ctd['SSS'])

    # Parametres figures 
    print 'min SSS',round(min(data_ctd['SSS']),2)
    print 'max SSS',round(max(data_ctd['SSS']),2)

    # PLOT CTD 
    number = '# '+str(int(number_ctd))
    outputname='figures/CTD_number-'+number_ctd+'.png'
    plot_ctd(data_ctd,outputname,number,'show_figure')

################################################################################################
# FONCTIONS 
################################################################################################
def read_line(filename):
    '''
    Read first line
    '''
    FileIn = open(filename,'rb') # apertura ficher
    for row in FileIn:
        line = str( row.strip().split(';'))
    return line

def plot_ctd(data,outputname,number,show_figure):
    '''
    PLOT CTD TEMPERATURE AND SALINITY DATA
    2 subplots
    '''   

    taille_map=(12,8)
    fig1=figure(facecolor='w',figsize=taille_map)
    plt.subplots_adjust(wspace=0.25,bottom=0.11,left=0.08,right=0.97,top=0.78,hspace=0.2)
    # PLOTTING TEMPERATURE
    ax=subplot(1,2,1)
    majorLocator   = MultipleLocator(4.0)
    majorFormatter = FormatStrFormatter('%1.1f')
    minorLocator   = MultipleLocator(1.0)
    ax.plot(data['SST'],data['prDM'],color='r',label='SST',linewidth=1.5,zorder=1)
    ylim([0,max(data['prDM'])+50])
    ax.xaxis.set_minor_locator(minorLocator)
    ax.xaxis.set_major_locator(majorLocator)
    ax.xaxis.set_major_formatter(majorFormatter)
    ylabel('Pres [db]')
    xlabel('Temperature') 
    ylim([0,max(data['prDM'])+50])
    grid('on')
    plt.gca().invert_yaxis()


    # PLOTTING SALINITY
    ax2=subplot(1,2,2)
    majorLocator   = MultipleLocator(0.5)
    majorFormatter = FormatStrFormatter('%1.1f')
    minorLocator   = MultipleLocator(0.1)
    ax2.plot(data['SSS'],data['prDM'],color='b',label='SSS',linewidth=1.5,zorder=1)
    ax2.xaxis.set_minor_locator(minorLocator)
    ax2.xaxis.set_major_locator(majorLocator)
    ax2.xaxis.set_major_formatter(majorFormatter)
    ylabel('Pres [db]')
    xlabel('Salinity')
    ylim([0,max(data['prDM'])+50])
    plt.gca().invert_yaxis()
    grid('on')
    lon = round((data['lon'][0]),2)
    lat = round((data['lat'][0]),2)
    titlename= 'CTD ' + number + ': [' + str(lat) + u'\N{DEGREE SIGN}N, ' + str(abs(lon))+  u'\N{DEGREE SIGN}W' +']'
    suptitle(titlename)

    a = axes([0.7, 0.795, .2, .2])
    # PLOT MAP PROJECTION
    map1 = Basemap(projection='cyl',llcrnrlat=latmin_r,urcrnrlat=latmax_r,llcrnrlon=lonmin_r,urcrnrlon=lonmax_r,resolution='l')
    # plot position of CTD
    map1.plot(lon,lat,marker='o',color='green',markeredgecolor='green')
    meridians_range=np.arange(-180,360,20)
    parallels_range=np.arange(-80,80,20)
    map1.drawcoastlines()
    map1.fillcontinents(color='grey')
    map1.drawmeridians(meridians_range, labels=[0,0,0,1],labelstyle=None)
    map1.drawparallels(parallels_range, labels=[1,0,0,0],labelstyle=None) 

    a.set_aspect('equal')
    for o in fig1.findobj(matplotlib.text.Text):
        o.set_size('16') 
    
    if show_figure=='yes':
        plt.show()
    else:    
        print 'saving figure ', outputname
        savefig(outputname, dpi=200 ) 

def read_ctd_file(filename,lonmin,lonmax,latmin,latmax):
    """"
    Reading variables of ctd file  
    """
    date=[]
    lat=[]
    lon=[]
    sal=[]
    sst=[]
    c=[]
    prDM=[]

    # New dict
    data_out = {}.fromkeys( ['time','lat','lon','SSS','SST','C','prDM'] )

    # OPEN TSG FILE
    FileIn = open(filename,'rb')
    titles = FileIn.next().strip().split(';') # Title of each row 
    # print titles, reading all row and lines
    for row in FileIn:
        values = row.strip().split(';' )
        data = dict(zip(titles, values))
        d1= data['timeJ']
        sss =np.float(data['SSS'])
        sstt =np.float(data['SST'])
        cc= np.float(data['C'])
        pp= np.float(data['prDM'])
        lati =np.float(data['lat'])
        longi= np.float(data['lon'])
        lat.append(lati)
        lon.append(longi)
        sal.append(sss)
        sst.append(sstt)
        c.append(cc)
        date.append(time)
        prDM.append(pp)

    data_out['prDM']=prDM
    data_out['time']=date
    data_out['SSS']=np.array(sal)
    data_out['SST']=np.array(sst)
    data_out['C']=np.array(c)
    data_out['lon']=np.array(lon)
    data_out['lat']=np.array(lat)
    return data_out

if __name__ == '__main__':
    main()

