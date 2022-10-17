let myvar: Int = 11;

let readdded: String? = readLine()

let readInt: Int = Int(readdded!)!;

print(myvar);
print(readdded!);


switch readInt {
    case 0: 
        print("Number \(readInt) is too small!");
    case 1...10:
        print("Number is between 1 and 10!");
    case 11,10: 
        print("Number is 10 or 11");
    default:
        print("Number is seomething different")
}