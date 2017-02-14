v = 1:275; 

% How many rows do we want to remove?
for n = 274:-1:1
    % What is every possible way in which we could remove said rows?
    combs = nchoosek(v,n);
    combsSize = size(combs);
    % Go through each possibility one-by-one
    for i = 1:combsSize(1)
        combsNext = combs(i,:);
        Xnext = X;
        % Remove said rows from the matrix
        for x = combsSize(2):-1:1
            x;
            Xnext(combsNext(x),:) = [];
        end
        % Find our new HCA 'c' value
        Cnext = HCA(Xnext);
        % Is it >0.90?
        if Cnext > .9 & ((sum(T(1:20)) == 40) & (sum(T(21:40) == 20)) | (sum(T(1:20)) == 40) & (sum(T(21:40) == 20)))
            return
        end
    end
end
