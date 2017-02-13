classdef IndexCrawler
    %Because MATLAB won't let you define >1 visible function...
    %   Detailed explanation goes here
    
    properties
        % gather the google sheet
        indexSheet = GetGoogleSpreadsheet('1w_082-Xox0uNFO0l5WLXKizrZlWOTxMGK4iIEL5ohi0')
        
        %Helpful indices CONST
        dateIndex = 1
        tissueTypeIndex = 2
        logIndex = 3
        dataIndex = 4
        headerIndex = 5
        
        % variable
        dateRow
        date
 
        
    end
    
    methods
        % constructor for one date
        function IC = IndexCrawler(date)
                      
            IC.dateRow = 2;
            IC.date = date;
           
            indexSheetSize = size(IC.indexSheet);
            while ~strcmp(IC.indexSheet{IC.dateRow},date)
                IC.dateRow = 1 + IC.dateRow;
                if IC.dateRow >= indexSheetSize(1)
                    disp('Date invalid');
                    IC.dateRow = 0;
                    IC.date = 'invalid';
                    break
                end
            end
        end
        
        
        
        % this is the heavy lifter for accessing the sheet and crawling!
        function logHeadOrData = GetAtIndex(IC, index)
            %GETATINDEX - gets log, header or header from a certain date
            logHeadOrData = GetGoogleSpreadsheet(IC.indexSheet{IC.dateRow, index});
        end
        
        % wrapper functions for above.. cells of strings
        function data = getData(IC)
            data = IC.GetAtIndex(IC.dataIndex);
        end
        function header = GetHeader(IC)
            header = IC.GetAtIndex(IC.headerIndex);
        end
        function log = GetLog(IC)
            log = IC.GetAtIndex(IC.logIndex);
        end
        
        % processes the cell into a matrix
        function dataMat = getDataMatrix(IC)
            data = IC.getData();
            numCell = data(2:end,1:end);
            numCellSize = size(numCell);
            for i= 1:numCellSize(1)*numCellSize(2)
                numCell{i} = str2num(numCell{i});
            end
            dataMat = cell2mat(numCell);
        end
        
        % get data matrix of normalized vectors!
        function normDataMat = getNormMatrix(IC)
            normDataMat = IC.getDataMatrix();
            dataMatSize = size(normDataMat);
            for i = 2:dataMatSize(2)
                starts = (dataMatSize(1)*(i-1))+1;
                ends = dataMatSize(1)*i;
                currentVector = normDataMat(starts:ends);
                normDataMat(starts:ends) = currentVector./sum(currentVector);
            end
        end
        
        
    end
    
    
    
    
    
end


