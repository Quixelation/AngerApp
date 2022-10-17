let myFirstArray = [Int]();

print(myFirstArray);


let myArrayWithDefaultValue = [Int](repeating: 0, count: 5)
print(myArrayWithDefaultValue);



var shoppingList: [String] = ["Bread"];

print("");
print("My Shopping List:")
print(shoppingList)

print("My Shhhhhhhhhhhh: \(shoppingList)")

if shoppingList.isEmpty {
    print("My Shpping List is Empty");
}else {
    print("My Shopping List contains \(shoppingList.count) items");
}


shoppingList.append("Milk");

// Needs to be an Array to be added onto an array
shoppingList += ["Cookies","Juice"]

shoppingList.insert("ChocciBread", at: 1)

print("My Shpping List Now: \(shoppingList)")
print("And the second item is \(shoppingList[1])")


for var (index, item) in shoppingList.enumerated() {
    print(item, "at",index);
}