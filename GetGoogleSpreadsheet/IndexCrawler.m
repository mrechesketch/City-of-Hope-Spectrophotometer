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
        
        
        
        
        function logHeadOrData = GetAtIndex(IC, index)
            %GETATINDEX - gets log, header or header from a certain date
            logHeadOrData = GetGoogleSpreadsheet(IC.indexSheet{IC.dateRow, index});
        end
        
        
        function data = getData(IC)
            data = IC.GetAtIndex(IC.dataIndex);
        end
        function header = GetHeader(IC)
            header = IC.GetAtIndex(IC.headerIndex);
        end
        function log = GetLog(IC)
            log = IC.GetAtIndex(IC.logIndex);
        end
        
        
        
    end
    
end

