let myPoint = (1,12);

switch myPoint{
    case let (x,y) where y > 10 && x < 2:
        print("Its that");
    default: 
        print("Hit the default statement");
}