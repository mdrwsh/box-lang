# box-lang
Box-lang is a high-level programming language written in Batch Script that compiles to native Batch script. This language intends to help solving some problems with Batch script like no specification of error and its hard syntax

## get started
This language only works on Windows as it use the native batch script that all Windows come with. NO DEPENDECIES.  

```
print "hello, world."
loop i 5
  print i + i
end
```  
  
write the code above inside a file such as `hello.box`, then compile with the compiler.  
  
```
box -c hello.box
```
  
this generates `out.bat` and can be run with
  
```
out
```
