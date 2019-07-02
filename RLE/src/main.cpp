#include "codec.h"



int main(int argc, char *argv[])
{
  if(argc < 4){
    std::cout << "\n Usage: $ ./coder [mode] [input file] [output file]"
        << "\n  Modes:" 
        << "\n    c - compress (block size is 1 byte)"
        << "\n    c1,c2,c4,c8 - compress with prefered block size(in bytes)"
        << "\n    d - decompress";
    return 1;
  }
  
  if((strcmp(argv[1], "c1") == 0) || (strcmp(argv[1], "c") == 0)){
    codec::Coder <uint8_t> a(argv[2]);
    a.write_code(argv[3]);
  }
  else if(strcmp(argv[1], "c2") == 0){
    codec::Coder <uint16_t> a(argv[2]);
    a.write_code(argv[3]);
  }
  else if(strcmp(argv[1], "c4") == 0){
    codec::Coder <uint32_t> a(argv[2]);
    a.write_code(argv[3]);
  }
  else if(strcmp(argv[1], "c8") == 0){
    codec::Coder <uint64_t> a(argv[2]);
    a.write_code(argv[3]);
  }
  else if(strcmp(argv[1], "d") == 0){
    int header = read_header(argv[2]);
    if(header == 1){
        codec::Coder <uint8_t> a;
        a.read_code(argv[2]);
        a.decode();
        a.write(argv[3]);
    }
    else if(header == 2){
        codec::Coder <uint16_t> a;
        a.read_code(argv[2]);
        a.decode();
        a.write(argv[3]);
    }
    else if(header == 4){
        codec::Coder <uint32_t> a;
        a.read_code(argv[2]);
        a.decode();
        a.write(argv[3]);
    }
    else if(header == 8){
        codec::Coder <uint64_t> a;
        a.read_code(argv[2]);
        a.decode();
        a.write(argv[3]);
    }
    else std::cerr << "\nError: Wrong header\n" << header;
  }
  std::cout << "Done!\n";
  return 0;
}
