#include <shell>

int glob = 1;

public main()
{
  static s_var = 100;
  glob++;
  --glob;
  if (glob++ == 2)
  	print("nope");
  if (--glob == 0)
  	print("yes");

  int var1 = 5;
  var1--;
  printnum(var1--);
  ++var1;
  printnum(++var1);
  if (glob > 1 && (var1 < 5 || --var1 == 4 || var1 > 10) && var1++ != 5)
  	print("local yup");
  ++s_var;
  s_var--;
  if (var1 > 2 && s_var-- > 20 || -1 < ++s_var)
  	print("static wat");
}
