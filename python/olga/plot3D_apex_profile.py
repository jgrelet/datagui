#!/usr/bin/env python
# -*- coding: utf-8 -*-

from numpy import arange, dtype # array module from http:/
#from matplotlib.toolkits.basemap import Basemap, shiftgrid
from mpl_toolkits.basemap import Basemap, shiftgrid
from pylab import *
import matplotlib.colors as colors
from optparse import OptionParser
import sys, os, locale
import glob
import math, numpy, re

import matplotlib.cbook as cbook
from matplotlib.ticker import FuncFormatter, MultipleLocator, FormatStrFormatter, LinearLocator
import matplotlib.text as text
import matplotlib.lines as mpllines
from mpl_toolkits.axes_grid.inset_locator import inset_axes

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from mpl_toolkits.mplot3d import Axes3D

__author__='OH'

################################################################################################
# MAIN 
################################################################################################

def main():

    # APEX folder 
    dir_folder='datos/'
    

    list_files=[]
    fecha=[]
    fecha2=[]
    lon_pos=[]
    lat_pos=[]
    number=1
    # reading all data 
    for apex_file in os.listdir(dir_folder): # for each file in the folder
        apex_data=apex_file[0:8]+'.msg'  # file with data
        apex_log=apex_file[0:8]+'.log'   # file position   
        if apex_file[9:12]=='msg':  # to not read two times the files
            print 'Reading File:... ' + apex_data
            print 'Reading File:... ' + apex_log    
                
            # Reading time in log file 
            os.system("sed '37q;d' <  datos/" + apex_data + " > out.txt") # always in line 37  
            os.system("awk '{print $2, $3, $4, $5}' out.txt > out2.txt")
            f,f2=read_date('out2.txt') 
            fecha.append(f)
            fecha2.append(f2)

            # Reading Position lon,lat in log fiile 
            # Fix:  -38.179  24.674 03/26/2013 184540   10
            string0="grep -n Fix:  datos/" + apex_log + "> line_to_cut "
            file_line=str(os.system(string0))
            os.system("awk '{print $9, $10 }' line_to_cut > line_to_cut2")
            string2= """awk 'NR == 1 { print "lon lat" } { print }' line_to_cut2 > line_to_cut3"""
            os.system(string2)
            os.system("rm line_to_cut  line_to_cut2")
            lon2,lat2=read_pos('line_to_cut3')
            lon_pos.append(lon2)
            lat_pos.append(lat2)

            # Modifing data format 
            # Atencion ficheros tiene que tenes este encabecamiento: " p t s TPhase Topt  FSig  BbSig  TSig" 
            string0= "sed '1,39d' <  datos/" + apex_data + "> data_v00_modif2" # always line 39
            os.system(string0)
            string1= "tr -s ' ' < data_v00_modif2 > data_v00_modif3" # que todos los espacios se quedan en une solo espacio
            os.system(string1) # ejecucion
            string3= """tr " " ";" <  data_v00_modif3 > data_v00_modif-"""  + str(number) # conversion de todos los espacios por ; 
            os.system(string3) # ejecucion
            os.system("rm data_v00_modif2 data_v00_modif3 out.txt out2.txt") # se borra esta fichero temporal
            apex_file2= 'data_v00_modif-' + str(number)
            number += 1
            list_files.append(apex_file2)
            
    # Reading all salinity data
    data_apex=[]
    for i in xrange(len(list_files)):     
        data_apex.append(reading_apex_file(list_files[i]))
    titlename ='Apex ' 

    # PLOT APEX 
    outputname='figures/perfilador_APEX_lonlatSSS.png'
    plot_apex(data_apex,lon_pos,lat_pos,outputname,'s')

    outputname='figures/perfilador_APEX_lonlatSST.png'
    plot_apex(data_apex,lon_pos,lat_pos,outputname,'t')

    # delete all temporary files
    os.system("rm data_v00_modif* ")

################################################################################################
# FONCTIONS 
################################################################################################

def read_pos(filename):
    '''
    Reading position in log file 
    '''
    FileIn = open(filename,'rb') # open file
    titles = FileIn.next().strip().split(' ')
    for row in FileIn: 
        values = row.strip().split(' ' )  
        data = dict(zip(titles, values)) 
        lon2=data['lon']
        lat2=data['lat']
    return lon2,lat2

def read_date(filename):
    '''
    Reading date on file 
    '''
    FileIn = open(filename,'rb') # apertura fichero
    tit_month=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    for row in FileIn:
        fecha = str( row.strip().split(';'))

    # very specific to this type of files
    m=str(fecha[2:5])
    for i in xrange(len(tit_month)):  
        if m == tit_month[i]:
            month= int(i+1)
    if month < 10:
        moisj='0'+str(month)
    else:   
        moisj=str(month)
    day=fecha[6:8]
    year=fecha[9:13]
    fecha2=str(year)+'_'+str(moisj)+'_'+str(day)+'_'+str(fecha[14:16])+'_'+str(fecha[17:19])+'_'+str(fecha[20:22])
    return fecha[2:len(fecha)-2],fecha2

def plot_apex(data,lon,lat,outputname,var):
    '''
    Figura perfilador APEX       
    '''

    taille_map=(12,8) # talla imagen
    fig1=figure(facecolor='w',figsize=taille_map)
    plt.subplots_adjust(wspace=0.25,bottom=0.11,left=0.08,right=0.97,top=0.89,hspace=0.2) # ajuste imagen margenes

    ax = fig1.gca(projection='3d')
 
    color_under=([0,0,0.1])
    color_over=([0.4,0.0,0.0])
    if var=='s':
        name_var='salinity'
        cmin=[36.0]
        cmax=[37.5]
    elif var=='t':
        name_var='temperature'
        cmin=[18.0]
        cmax=[24.0]

    ticks_range1=[2]
    ticks_range2=[20]
    t_lab=np.linspace(cmin[0],cmax[0], ((cmax[0]-cmin[0]) * ticks_range1[0]+1) ) 
    t=np.linspace(cmin[0],cmax[0], ((cmax[0]-cmin[0])*ticks_range2[0]+1) )
    
    # plot of each profile  
    for i in xrange(len(lon)): # len(lon) = number of profiles 
        X = lon[i]
        Y = lat[i]
        nX=np.zeros(len(data[i]['p']))
        nY=np.zeros(len(data[i]['p']))
        for j in xrange(len(data[i]['p'])):    
            nX[j]=lon[i]
            nY[j]=lat[i]  
        Z = np.array(data[i]['p'])
        S = data[i][var]   
        surf=ax.scatter3D(nX,nY,-Z,c=S, s=20.0, norm = colors.BoundaryNorm(t,ncolors=256, clip = False),edgecolor='none')

    # titulos
    ax.set_xlabel('Lon',linespacing=3) 
    ax.set_ylabel('Lat',linespacing=3) 
    ax.set_zlabel('Pres [db]',linespacing=3)

    ax.yaxis.set_major_formatter(FormatStrFormatter('%.01f'))
    ax.xaxis.set_major_formatter(FormatStrFormatter('%.01f'))

    cb=plt.colorbar(surf,ticks=t_lab,orientation='vertical', extend='both',pad=0.05,shrink=0.8)
    cb.set_label(name_var)       
    surf.cmap.set_over(color_over)
    surf.cmap.set_under(color_under)

    ax.set_zlim([-350,0])
    setp( ax.get_zticklabels(), visible=True) 
    nz2=['350','300','250','200','150','100','50','0']
    ax.set_zticklabels(nz2)   

    ax.azim = -72
    ax.elev = 28 
    titlename= 'Perfilador APEX: '+ name_var

    suptitle(titlename)
    for o in fig1.findobj(matplotlib.text.Text):
        o.set_size('16') 

    plt.show()

    print 'saving figure ', outputname
    savefig(outputname, dpi=200 ) 


def reading_apex_file(filename):
    """"
    Lecture fichero APEX 
    """
    # fichero de salida
    data_out = {}.fromkeys( ['p','t','s','TPhase','Topt','FSig','BbSig','TSig'] )  # con nombre de las columnas del fichero filename
    # inicializacion dictionario
    for key in data_out.keys():
        data_out[key]=[]

    FileIn = open(filename,'rb')
    titles = FileIn.next().strip().split(';')  # lectura encabezamientos separados por ;
    # print titles
    test=0
    for row in FileIn: # para cada linea en el fichero
        values = row.strip().split(';' ) # valores de a linea separados por ;  
        data = dict(zip(titles, values)) # juntamos datos con encabezamientos
        # para cada nombre del dictionario
        if data['$'] != '#' and test==0:
            for key in data_out.keys():
                if len(values)!=6:
                    if len(data[key]) != 0:
                        data_out[key].append(np.float(data[key])) # guardamos valores de cada columna         
                else:
                    if key == 'Topt' or key=='FSig' or key=='BbSig' or key=='TSig':
                        data_out[key].append('NaN')   
                    else:
                        if len(data[key]) != 0:
                            data_out[key].append(np.float(data[key])) # guardamos valores de cada columna   
        else:
           test=1

    return data_out


if __name__ == '__main__':
    main()

