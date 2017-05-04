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
        %log and header
        logID
        headerID
        % linked list!
        next 
   
    end
    
    methods
        
        % construct it on its string representation
        function DS = DataSet(dataStr, logID, headerID, dataSetNode)
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
            % save other parameters
            DS.logID = logID;
            DS.headerID = headerID;
            DS.next = dataSetNode;
            
            
        end
        
        % helper functions for processing single vector
        function [normVec, factor] = normVector(~, vector)
            factor = sum(vector);
            normVec = vector./factor;
        end
        
        % Correct for flourescence using msbackadj
        function [corr, factor] = corr(DS, vector)
            corr = msbackadj(DS.x, vector);
            corrSub = vector-corr;
            factor = sum(corrSub);
        end
        
        % Returns a vector of length n-1 for derivative
        function [deriv, factor] = deriv(DS, vector, order)
            if order > 0
                % get differences
                stepSizes = diff(DS.x);
                yDiff = diff(vector);
                % set first and last
                vector(1) = yDiff(1) / stepSizes(1);
                vector(end) = yDiff(end) / stepSizes(end);
                % loop the rest considering both sides of i
                for i = 2:length(vector)-1
                    deltaY = yDiff(i-1)+yDiff(i);
                    deltaX = stepSizes(i-1)+stepSizes(i);
                    vector(i) = deltaY / deltaX;
                end
                % recursive call
                DS.deriv(vector, order-1);
            end
            
            deriv = vector;
            factor = 0;
                                   
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
                if contains(type, 'corr')
                    [transform, factor] = DS.corr(currentVector');
                end
                if contains(type, 'norm')
                    [transform, factor] = DS.normVector(currentVector);
                end
                if contains(type, 'deriv')
                    order = str2num( replace(type, 'deriv', '') );
                    [transform, factor] = DS.deriv(currentVector, order);
                end
                % set the values
                factors(i) = factor;
                transformed(starts:ends) = transform;
            end
            isequal(transformed, data);
        end
        
        % wrappers for apply process
        function transformed = getNorm(DS)
            transformed = DS.applyProcess(DS.data, 'norm');
        end
        
        function transformed = getCorr(DS)
            transformed = DS.applyProcess(DS.data, 'corr');
        end
        
        function transformed = getNormCorr(DS)
            transformed = DS.getCorr();
            transformed = DS.applyProcess(transformed, 'norm');
        end
    
            
       
            
    end
    
end

