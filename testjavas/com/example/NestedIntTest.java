package com.example;
public interface NestedIntTest {
    public static final int USELESS_CONSTANT = 4;
    public abstract int[][] array_returner(
        java.lang.String s, int i, float[] f, float[][] g
    );

    public abstract java.lang.String object_returner()
        throws java.lang.NumberFormatException, java.lang.Exception;
    public abstract java.lang.String object_returner( java.lang.String s )
        throws java.lang.NumberFormatException;

    public abstract void void_returner( int i );
}
