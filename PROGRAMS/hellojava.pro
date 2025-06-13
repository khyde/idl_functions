;
; Copyright (c) 2002-2011, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: 'hello world' type example using Java in IDL
;
; Usage:
;    IDL> helloJava
;
;
 
pro HELLOJAVA

  ; Create a 'HelloJava' Java object and have it say hello in IDL.

  ; Create the object first
  joHello = OBJ_NEW("IDLJavaObject$HelloJava", "HelloJava")

  ; Call the 'sayHello' method on the object.  This sends a message to 
  ; System.out, which shows up in IDL.
  joHello->sayHello

  ; delete the object
  OBJ_DESTROY, joHello

end
