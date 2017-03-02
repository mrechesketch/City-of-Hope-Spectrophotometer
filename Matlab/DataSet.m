classdef DataSet
    %Data set class allows user to make transformations on data
    % and keeps track of said transforms
    
    properties
        titles
        x
        data
        % dimesions
        height 
        width
        % paramters for process functions
        polyOrder = 7
    end
    
    methods
        
        % construct it on its string representation
        function DS = DataSet(dataStr)
            % titles first
            DS.titles = dataStr(1,2:end);
            % then convert strings to numbers
            xAndDataCell = dataStr(2:end,1:end);
            numCellSize = size(xAndDataCell);
            for i= 1:numCellSize(1)*numCellSize(2)
                xAndDataCell{i} = str2num(xAndDataCell{i});
            end
            xAndData = cell2mat(xAndDataCell);
            % split the x and data
            DS.x = xAndData(1:end,1);
            DS.data = xAndData(1:end,2:end);
            % get height and width of data
            [DS.height, DS.width] = size(DS.data);
            %test
            DS.normVector([1,1]);
            
        end
        
        % helper functions for processing single vector
        function [normVec, factor] = normVector(~, vector)
            factor = sum(vector);
            normVec = vector./factor;
        end
        
        % Subtract a n order polynomial from a vector
        function [corr, factor] = corr(DS, vector)
            corr = msbackadj(DS.x, vector);
            corrSub = vector-corr;
            factor = sum(corrSub);
        end
        
        % function that act on any data set
            % input: data set and the type of transformation
            % output: transformed data set and factors associated
        function [transformed, factors] = applyProcess(DS, data, type)
            transformed = data;
            [h, w] = size(data);
            factors = zeros([1,w]);
            for i = 1:w
                starts = (h*(i-1))+1;
                ends = h*i;
                currentVector = transformed(starts:ends);
                % make the choice on type
                if strcmp(type, 'corr')
                    [transform, factor] = DS.corr(currentVector');
                end
                if strcmp(type, 'norm')
                    [transform, factor] = DS.normVector(currentVector);
                end
                % set the values
                factors(i) = factor;
                transformed(starts:ends) = transform;
            end
        end
       
            
    end
    
end

