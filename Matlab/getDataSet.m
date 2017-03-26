function dataSetNode = getDataSet( date )
%This function replaces index crawler. 
%   You give this function a date and it returns a dataset node that
%   is part of a linked list

        % gather the google sheet
        indexSheet = GetGoogleSpreadsheet('1w_082-Xox0uNFO0l5WLXKizrZlWOTxMGK4iIEL5ohi0');
        
        %Helpful indices CONST
        logIndex = 3;
        dataIndex = 4;
        headerIndex = 5;
        
        % first step, get the date row indices
        dateRows = [];
        [height, ~] = size(indexSheet);
        for i =1:height
            if strcmp(indexSheet{i}, date)
                % append the index i to date rows
                dateRows = [dateRows i];
            end
        end
        if isequal(dateRows, [])
            disp('Date not found')
            return
        end
        
        
        % next step, iterate through dateRows and create dataSet nodes
        i = 1;
        lastDataNode = 'null';
            % remeber tissue types
        tissueTypes = [];
        while i <= length(dateRows)
            % get ID's
            logID = indexSheet{dateRows(i), logIndex};
            dataID = indexSheet{dateRows(i), dataIndex};
            headerID = indexSheet{dateRows(i), headerIndex};
            % create dataStr
            dataStr = GetGoogleSpreadsheet(dataID);
            % create data set node
            currentDataNode = DataSet(dataStr, logID, headerID, lastDataNode);
            lastDataNode = currentDataNode;
            % increment i
            i = 1 + i;          
        end
        
        dataSetNode = currentDataNode;
        % output display message
        displayMessage = strcat(num2str(length(dateRows)), ' data sets retrieved');
        disp(displayMessage);
  


end



