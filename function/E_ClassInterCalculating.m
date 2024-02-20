function E_ClassInter = E_ClassInterCalculating(region_class,HashTable,Guiding)

rgnCount = size(region_class,1);

if Guiding == 1
    NumClass = size(HashTable,1);
    E_ClassInter = zeros(rgnCount,NumClass);
    for i = 1:NumClass
        cenclass = i*ones(rgnCount,1);
        energy = HashTable(sub2ind(size(HashTable),cenclass,region_class));
        energy(energy==1) = -1;
        energy(energy==0) = 1;
        E_ClassInter(:,i) = energy;
    end

elseif Guiding == 2
    NumClass = size(HashTable,2);
    E_ClassInter = zeros(rgnCount,NumClass);
    for i = 1:NumClass
        cenclass = i*ones(rgnCount,1);
        energy = HashTable(sub2ind(size(HashTable),region_class,cenclass));
        energy(energy==1) = -1;
        energy(energy==0) = 1;
        E_ClassInter(:,i) = energy;
    end
else
    error('Specify parameter error！')
end
