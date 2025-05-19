package com.example;

public class Handler implements com.amazonaws.services.lambda.runtime.RequestHandler<String,String>{
    @Override public String handleRequest(String in, com.amazonaws.services.lambda.runtime.Context ctx){
        return "hello " + in;
    }
}
