import os

class TableCreator:

    def __init__(self, wavelength):
        """
        the divider string between header and data is the same for either 
        the 1064 or 785 system. Their relative wavenumber ranges are not.
        """
        self.dividerString_ = "\nPixel"
        if wavelength == 785:
            self.START = 177
            self.END = 1980
        if wavelength == 1064:
            self.START = 58
            self.END = 486
        """
        indices of ramanshift, dark and raw data are invariant. The indices
        refer to the column position of the data vector
        """
        self.RAMANSHIFT = 3
        self.DARK = 4
        self.RAWDATA = 6
        """
        locations and files start as empty lists 
        """
        self.locations = []
        self.files = [] 

    
    def createTable(name):
        """
        user provides the location of a folder containing text files and 
        these are reduced to a single table
        """
        return 0

    def addLocation(locationString):
        return 0


            



STARTFORDATA = "\nPixel"

STARTFOR785 = 177 # 176 is start index on txt
ENDFOR785 = 1980 # 1979 is the end
indices785 = [STARTFOR785, ENDFOR785]

STARTFOR1064 = 58 # 57 is start
ENDFOR1064 = 486 # 485 is end
indices1064 = [STARTFOR1064, ENDFOR1064]

RAMANSHIFT = 3
DARK = 4
RAWDATA = 6
dataFolder = "C:\Users\octopus\Documents\BwtekData"
desktopLoc = "C:\Users\octopus\Desktop\Nov21 SNR Calcite"
files = os.listdir(dataFolder)


# gather files from a day
def getFilesFromDay(dateString):
    titles = filter(lambda x: dateString in x, files) 
    return titles 

# take in file path and retrieve string header
# TODO MAKE THIS BETTER??
def getData(name):
    f = open(desktopLoc + "\\" + name)
    r = f.read()
    f.close()
    startIndex = r.find(STARTFORDATA)
    data = r[startIndex+1:len(r)]
    return data

def listOfListData(data):
    splitLines = data.split("\n")
    return map(lambda x: x.split(";")[:-1], splitLines)[:-1]

def getVector(DataIndex, LOLData):
    return map(lambda x: x[DataIndex], LOLData)

def getRaman(LOLData):
    return getVector(RAMANSHIFT, LOLData)

def getDark(LOLData):
    return getVector(DARK, LOLData)

def getRaw(LOLData):
    return getVector(RAWDATA, LOLData)

#sampleDay = getFilesFromDay("Nov1")
#sampleData = getData(sampleDay[0])

def processExp(ExpData):
    LOLData = listOfListData(ExpData)
    [start, end] = indices1064
    raman = getRaman(LOLData)[start:end]
    dark = getDark(LOLData)[start:end]
    raw = getRaw(LOLData)[start:end]
    dataSeries = map(lambda x,y: str(float(x)-float(y)), raw,dark)
    r = map(lambda x: x, raman)
    return map(lambda x: [x[0],x[1]], zip(r, dataSeries))

def combineData(dataLOLA, dataLOLB):
    map(lambda x: x[0].append(x[1][1]), zip(dataLOLA, dataLOLB))
    return dataLOLA

# convert LOL to comma separation
def LOLToCSV(lolHList):
    return map(lambda x: reduce(lambda a,b: a+','+b, x),lolHList)

def titleString(dateString):
    #titles = getFilesFromDay(dateString)
    titles = os.listdir(desktopLoc)
    return "Raman Shift," + reduce(lambda x,y: x + "," + y, titles)+ "\n"

# convert LOS to \n string
def restString(LOLCSV):
    rest = reduce(lambda x,y: x + "\n" + y, LOLCSV)
    return rest

def createDataTxt(dateString):
    sampleDay = getFilesFromDay(dateString)
    lDList = map(lambda x: processExp(getData(x)), sampleDay)
    zz = reduce(combineData, lDList)
    commaSeparatedElements = LOLToCSV(zz)
    writeString = titleString(dateString) + restString(commaSeparatedElements) 
    f = open(dateString + "Data.txt", 'w')
    f.write(writeString)
    f.close()
    return

def createDataFromFolder(dateString):
    sampleDay = os.listdir(desktopLoc)
    lDList = map(lambda x: processExp(getData(x)), sampleDay)
    zz = reduce(combineData, lDList)
    commaSeparatedElements = LOLToCSV(zz)
    writeString = titleString(dateString) + restString(commaSeparatedElements) 
    f = open(dateString + "Data.txt", 'w')
    f.write(writeString)
    f.close()
    return



