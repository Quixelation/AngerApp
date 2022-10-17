var myOneOfAKindSet: Set<String> = ["Robert","Paul","Triss","Clemens"];
var myEmptySet = Set<String>();

print(myOneOfAKindSet);
print(myEmptySet);



var allMembersAreHere = false;

while !allMembersAreHere {

if myOneOfAKindSet.contains("David") {
    print("David is here");
    allMembersAreHere = true;
}else{
    print("David aint here");
    print("Adding David...");
    myOneOfAKindSet.insert("David")
}

}


print(myOneOfAKindSet.sorted())
