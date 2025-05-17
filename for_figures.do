version 8.0
clear
set logtype t
set more off
set mem 50m
set matsize 800
cap log close

log using figures,replace t
/***************************************************************************************************/

/*Commands for graphs*/

u WE_Data0			
/*The data set contains the household identifier and the response to the first question on stock price expectations from the SHIW for 2008*/

lab var probors1 "% chance of stock market gain"
histogram probors1, xlabel(0(10)100) graphregion(fcolor(gs16)) bcolor(black) bin(35)

clear

u for_figure2	
/*Data from Yahoo Finance on the Italian FTSE MIB for 2008-2010*/

histogram  var3 if year>2007 & year<2011, kdensity normal xlabel(-.70(.20).7) graphregion(fcolor(gs16)) bcolor(black) bin(30)

log c
