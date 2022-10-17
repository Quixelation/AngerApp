var myPersonDict = [String: String]();

myPersonDict["name"] = "David";

print(myPersonDict);


var oldName = myPersonDict.updateValue("Triss", forKey: "name")
print(myPersonDict);

var removedName = myPersonDict.removeValue(forKey: "name")
print(myPersonDict);





var secondPerson: [String : Any] = ["name":"Robert", "age": 17, "nick":"rob", "school":"Angergymnasium"];


for personDetail in secondPerson {
    print(personDetail.key , " :: " , personDetail.value)
}


for personKey in secondPerson.keys {
    print(personKey);
}