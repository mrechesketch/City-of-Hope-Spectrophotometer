# City-of-Hope-Spectrophotometer
2016-2017 Harvey Mudd College Clinic Project

Contributors: Sarah Anderson, Alex Echevarria, Nathan Miller, Connor Stashko

Most of this project is written in MATLAB however there is one Python file. 

The Python (TableCreator.py) file aggregates spectra files into two types of tables: data and header. Header contains parameters of the experiment (i.e. number of scans, integration time, date and time of experiment, etc..) and the data contains columns of the Raman Shifted intensities - dark.

These tables exist as Google Spreadsheets that are publically accessible. Using code from https://www.mathworks.com/matlabcentral/fileexchange/39915-getgooglespreadsheet?focused=5837514&tab=function these data tables can be accessed. 

The getDataSet function leverages a GoogleSheet called Index with the DOCID's of all data and header tables. The DataSet class allows the user to easily make transformations on the spectra like fluorescence correction, normalization and n-derivatization.    