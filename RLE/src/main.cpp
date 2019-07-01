#include "codec.h"



int main(int argc, char *argv[])
{
  /*codec::File f;
  f.push(uint64_t(0b00111010101010));
  f.push(uint8_t(0b100000000));
  f.push(uint32_t(0b11110000011001100));
  f.write(argv[1]);
  //  std::cout << "0x" << std::setfill('0') << std::setw(8) << std::hex << (0b111 & 0b1);
    */
  if(argc < 3){
    return 1;
  }
  
  if(strcmp(argv[1], "e1") == 0){
    codec::Coder <uint8_t> a(argv[2]);
    a.encode();
  }
  
  if(strcmp(argv[1], "c1") == 0){
    codec::Coder <uint8_t> a(argv[2]);
    a.analize();
    a.write(argv[3]);
  }
  else if(strcmp(argv[1], "c2") == 0){
    codec::Coder <uint16_t> a(argv[2]);
    a.analize();
    a.write(argv[3]);
  }
  else if(strcmp(argv[1], "c4") == 0){
    codec::Coder <uint32_t> a(argv[2]);
    a.analize();
    a.write(argv[3]);
  }
  else if(strcmp(argv[1], "c8") == 0){
    codec::Coder <uint64_t> a(argv[2]);
    a.analize();
    a.write(argv[3]);
  }
  return 0;
}
