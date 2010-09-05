public class dupMethodTest {
    public static final int INT_CONST = 4;
    public static final double FLOAT_CONST = 4.2;
    public static final java.lang.String A_STRING_CONST = "A string";
    public static final java.lang.String B_STRING_CONST = "A 'str' & \back";
    // public static final java.lang.String C_STRING_CONST = "A \\u2297='\u2297'"; not working
    public dupMethodTest() {}
    
    // the following 2 methods end up with the same method signature
    // using the default TypeCast translations
    public java.lang.String dupMethod(int number) {return "";}
    public java.lang.String dupMethod(char num) {return "";}
    
    // this one should have a different signature 
    public java.lang.String dupMethod(java.lang.String[] num) {return "";}
    
    public int nonDupedMethod(char num) {return INT_CONST;}
}    
    
    
