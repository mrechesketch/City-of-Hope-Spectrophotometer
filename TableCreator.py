import os

class TableCreator:

    def __init__(self, wavelength):
        """
        The divider string between header and data is the same for either 
        the 1064 or 785 system.
        """
        self.dividerString_ = "\nPixel"
        """
        Their relative wavenumber ranges are not.
        """
        if wavelength == 785:
            self.START = 182
            self.END = 1986
        if wavelength == 1064:
            self.START = 58
            self.END = 486 
        """
        Indices of ramanshift, dark and raw data are invariant. The indices
        refer to the column position of the data vector
        """
        self.RAMANSHIFT = 3
        self.DARK = 4
        self.RAWDATA = 6
        """
        Locations and files start as empty strings 
        """
        self.location = ""
        self.files = ""

    # Public Methods 
    def createTables(self, userName):
        self.createDataTable(userName)
        self.createHeaderTable(userName)
        return

    def addLocation(self, locationString):
        """
        Add the location of files to be reduced
        """
        self.location = locationString
        self.addFiles(locationString)
        return

    def addFiles(self, locationString):
        """
        Filter the files so only text files are reduced
        """
        allFiles = os.listdir(self.location)
        self.files = filter(lambda x: ".txt" in x, allFiles)
        return

    #Private Methods

    def dataOrHeader(self, name, doH):
        """
        Return either the second half (data, dOH==True) or
        first half of string (header, dOH==False)
        """
        f = open(self.location + "/" + name)
        r = f.read()
        f.close()
        index = r.find(self.dividerString_)
        dataOrHeader = r[index+1:len(r)] if doH else r[0:index]
        #hacky fix for random \r
        dataOrHeader = dataOrHeader.replace("\r", "") 
        return dataOrHeader
    
    def getData(self, name):
        return self.dataOrHeader(name, True)

    def getHeader(self, name):
        return self.dataOrHeader(name, False)

    def listOfListData(self, dataString):
        splitLines = dataString.split("\n")
        return map(lambda x: x.split(";")[:-1], splitLines)[:-1]

    def lolHeader(self, headerString):
        lineSplit = headerString.split("\n")
        return map(lambda x: x.split(";"), lineSplit)

    def getVector(self, DataIndex, LOLData):
        return map(lambda x: x[DataIndex], LOLData)

    def getRaman(self, LOLData):
        return self.getVector(self.RAMANSHIFT, LOLData)

    def getDark(self, LOLData):
        return self.getVector(self.DARK, LOLData)

    def getRaw(self, LOLData):
        return self.getVector(self.RAWDATA, LOLData)

    def processExp(self, ExpData):
        """
        This method takes in the data string and performs some
        light processing. The dark signal is subtracted from the
        response and the raman shift is zipped to this resulting value
        """
        LOLData = self.listOfListData(ExpData)
        raman = self.getRaman(LOLData)[self.START:self.END]
        dark = self.getDark(LOLData)[self.START:self.END]
        raw = self.getRaw(LOLData)[self.START:self.END]
        dataSeries = map(lambda x,y: str(float(x)-float(y)), raw,dark)
        #r = map(lambda x: x, raman)
        return map(lambda x: [x[0],x[1]], zip(raman, dataSeries))

    def combineData(self, dataLOLA, dataLOLB):
        """
        Every file has a common raman shift we only 
        really need to include it from the first one (that's why
        x[1][1] is appended and not x[1][0]!)
        """
        map(lambda x: x[0].append(x[1][1]), zip(dataLOLA, dataLOLB))
        return dataLOLA


    def LoLToCSV(self, LoL):
        """
        Convert a list of lists into a list where each element is one
        long string and values are separated by a comma
        """
        return map(lambda x: reduce(lambda a,b: a+','+b, x),LoL)

    def titleString(self):
        titles = reduce(lambda x,y: x + "," + y, self.files)
        return "Raman Shift," + titles + "\n"


    def restString(self, LoLCSV):
        rest = reduce(lambda x,y: x + "\n" + y, LoLCSV)
        return rest

    def createTable(self, userName, doH):
        lList = map(lambda x: 
        self.processExp(self.getData(x)) if doH else 
        self.lolHeader(self.getHeader(x)) , self.files)
        # this method is kinda magic
        zz = reduce(self.combineData, lList)
        commaSepElements = self.LoLToCSV(zz)
        writeString = self.titleString() + self.restString(commaSepElements)
        extension = "Data.txt" if doH else "Header.txt"
        f = open(userName + extension, 'w')
        f.write(writeString)
        f.close()
        return

    def createDataTable(self, userName):
        self.createTable(userName, True)
        return

    def createHeaderTable(self, userName):
        self.createTable(userName, False)
        return

d = TableCreator(785)
d.addLocation("/Users/alexanderechevarria/Desktop/Spring 2017/Clinic/temp")
d.createTables("Calibration")
