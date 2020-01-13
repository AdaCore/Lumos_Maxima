with AWS.Translator;
with GNAT.Regpat;

package body Util is

   function Strip(The_String: String; The_Characters: String) return String;

   Re : constant GNAT.Regpat.Pattern_Matcher :=
     GNAT.Regpat.Compile ("<[[:print:]]+?>");

   -------------------
   -- Extract_Email --
   -------------------

   function Extract_Email (Key : String) return String_Lists.List is
      use GNAT.Regpat;
      Clean_Key : constant String := Strip (Key, " " & ASCII.CR & ASCII.LF);
      Dec : constant String := AWS.Translator.Base64_Decode (Clean_Key);
      Current : Natural := Dec'First;
      Matches : Match_Array (0 .. 0);
      Result : String_Lists.List := String_Lists.Empty_List;
   begin
      loop
         Match (Re, Dec, Matches, Current);
         exit when Matches (0) = No_Match;
         Result.Append (Dec (Matches (0).First + 1 .. Matches (0).Last - 1));
         Current := Matches (0).Last + 1;
      end loop;
      return Result;
   end Extract_Email;

   -----------
   -- Strip --
   -----------

   function Strip(The_String: String; The_Characters: String)
                  return String is
      Keep:   array (Character) of Boolean := (others => True);
      Result: String(The_String'Range);
      Last:   Natural := Result'First-1;
   begin
      for I in The_Characters'Range loop
         Keep(The_Characters(I)) := False;
      end loop;
      for J in The_String'Range loop
         if Keep(The_String(J)) then
            Last := Last+1;
            Result(Last) := The_String(J);
         end if;
      end loop;
      return Result(Result'First .. Last);
   end Strip;

end Util;
