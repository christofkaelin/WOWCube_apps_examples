//number/ example 12345, num0_pic = start pic with zero
DrawNumber(const c_number, const c_num0_pic, const c_x, const c_y, const c_shift_x, const c_shift_y, const c_angle)
{
  new base = 10;
  new x = c_x;
  new y = c_y;
  //new tmp = c_number;
  while (base <= c_number)
  {
    base *= 10;
  }
  //base /= 10;
  while (base >= 10)
  {
    base /= 10;
    abi_CMD_BITMAP( c_num0_pic + c_number/base%10, x, y, c_angle, MIRROR_BLANK); 
    x += c_shift_x;
    y += c_shift_y;
  }
}