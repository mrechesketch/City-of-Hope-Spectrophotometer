classdef IndexCrawler
    % Access indexed data
    
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
                if IC.dateRow > indexSheetSize(1)
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
        function data = getDataStr(IC)
            data = IC.GetAtIndex(IC.dataIndex);
        end
        function header = GetHeader(IC)
            header = IC.GetAtIndex(IC.headerIndex);
        end
        function log = GetLog(IC)
            log = IC.GetAtIndex(IC.logIndex);
        end

        % get a data set object
        function DS = getDataSet(IC)
            dataStr = IC.getDataStr();
            DS = DataSet(dataStr);
        end
        
        
        
    end
    
    
    
    
    
end


