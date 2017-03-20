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
        dateRows = []
        date
 
        
    end
    
    methods
        % constructor for one date
        function IC = IndexCrawler(date)
                      
            IC.date = date;
           
            [height, ~] = size(IC.indexSheet);
            for i =1:height
                if strcmp(IC.indexSheet{i}, date)
                    % append the index i to date rows
                    IC.dateRows = [IC.dateRows i];
                end
            end
            if isequal(IC.dateRows, [])
                disp('Date not found')
                IC.date = 'invalid';
            end
                

        end
        
        
        
        % this is the heavy lifter for accessing the sheet and crawling!
        function logHeadOrData = getAtIndex(IC, index)
            %GETATINDEX - gets log, header or header from a certain date
            % hacky fix only first element relevant (for meow)
            dateRow = IC.dateRows(2);
            logHeadOrData = GetGoogleSpreadsheet(IC.indexSheet{dateRow, index});
        end
        
        % wrapper functions for above.. cells of strings
        function data = getDataStr(IC)
            data = IC.getAtIndex(IC.dataIndex);
        end
        function header = getHeader(IC)
            header = IC.getAtIndex(IC.headerIndex);
        end
        function log = getLog(IC)
            log = IC.getAtIndex(IC.logIndex);
        end

        % get a data set object
        function DS = getDataSet(IC)
            dataStr = IC.getDataStr();
            logStr = IC.getLog();
            headerStr = IC.getHeader();
            DS = DataSet(dataStr, logStr, headerStr, 'null');
        end
        
        
        
    end
    
    
    
    
    
end


