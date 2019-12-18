with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
package Keys is

   subtype Key_Type is Unbounded_String;

   No_Key : constant Key_Type;
   
   function From_String (S : String) return Key_Type;
   function To_String (S : Key_Type) return String;
private

   No_Key : constant Key_Type := Null_Unbounded_String;
   
   function From_String (S : String) return Key_Type is
      (To_Unbounded_String (S));
   
   function To_String (S : Key_Type) return String is
      (Ada.Strings.Unbounded.To_String (S));
end Keys;
