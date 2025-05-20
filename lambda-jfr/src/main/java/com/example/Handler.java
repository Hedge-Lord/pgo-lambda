package com.example;

public class Handler implements com.amazonaws.services.lambda.runtime.RequestHandler<String,String>{
    @Override public String handleRequest(String in, com.amazonaws.services.lambda.runtime.Context ctx){
        if ("exit".equals(in)) System.exit(0);
        return "hello " + in;
    }
}
