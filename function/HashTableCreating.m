function HashTable = HashTableCreating(k,rgnSubclass)

HashTable = zeros(k,sum(rgnSubclass));
Num = 0;
for i = 1:k
HashTable(sub2ind(size(HashTable),repmat(i,rgnSubclass(i),1),(Num+1:rgnSubclass(i)+Num)')) = 1;
Num = Num + rgnSubclass(i);
end

end
