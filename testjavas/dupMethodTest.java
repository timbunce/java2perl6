public class dupMethodTest {
    public static final int USELESS_CONSTANT = 4;
    public dupMethodTest() {}
    
    // the following 2 methods end up with the same method signature
    // using the default TypeCast translations
    public java.lang.String dupMethod(int number) {return "";}
    public java.lang.String dupMethod(char num) {return "";}
    
    // this one should have a different signature 
    public java.lang.String dupMethod(java.lang.String[] num) {return "";}
    
    public int nonDupedMethod(char num) {return USELESS_CONSTANT;}
}    
    
    