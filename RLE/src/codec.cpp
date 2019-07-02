#include "codec.h"


int read_header(const char * fname){
    std::ifstream f(fname, std::ios::binary | std::ios::in);
    char c = 0;
    f.get(c);
    f.close();
    return uint8_t(c);
}

using namespace codec;

/************************************
**  CODER:
************************************/

template <class T>
Coder<T>::Coder(const char * fname){
  data_length = 0;
  data = new T[1];
  data_space = 1;
  read(fname);
}

template <class T>
Coder<T>::Coder(){
  data_length = 0;
  data = new T[1];
  data_space = 1;
}


template <class T>
void Coder<T>::write(const char * fname){
  std::ofstream f (fname,std::ofstream::binary);
  T buf;
  char *s = new char;
  
  const int block_size = sizeof(buf)/sizeof(*s);
  const int r_block_size = sizeof(*s) * 8;
  
  for(uint32_t i = 0; i < data_length; i++){
    buf = data[i];
    for(int p = block_size - 1; p >= 0; p--){
      *s = buf >> (r_block_size * p);
      f.write(s, 1);
    }
  }
  
  f.close();
}


template <class T>
void Coder<T>::read(const char * fname){
  std::ifstream f(fname, std::ios::binary | std::ios::in);
  char c;
  T buf;

  const int block_size = sizeof(buf)/sizeof(c);
  const int r_block_size = sizeof(c) * 8;
  int i = block_size -1;

  while (f.get(c))
  {
    if(i == 0) {
      i = block_size -1;
      buf = buf | T(uint8_t(c));
      add(buf);
      buf = 0;
    }
    else {
      buf = buf | ( T(uint8_t(c)) << (r_block_size * i));
      --i;
    }
  }
  if(i != block_size){
    add(buf);
  }
  f.close();
}

template <class T>
void Coder<T>::check_space(){
  if(data_length < data_space) return;
  expand();
}

template <class T>
void Coder<T>::expand(){
  data_space *= 2;
  T * tmp = data;
  data = new T[data_space];
  for(uint64_t i = 0; i < data_length; i++){
    data[i] = tmp[i];
  }
  delete[] tmp;
}

template <class T>
void Coder<T>::add(T value){
  check_space();
  data[data_length] = value;
  data_length++;
}

template <class T>
void Coder<T>::analize(){
  T buf;
  if (data_length > 0) {
    buf = data[0];
    freq_map.add(data[0]);
  }
  for(uint32_t i = 1; i < data_length; i++){
    if(buf != data[i]){
      buf = data[i];
      freq_map.add(data[i]);
    }
  }
  freq_map.sort();
  freq_map.print(); //????????????????????
  
  std::cout << "\n\nn: " << freq_map.get_num(0xa8); //????????????????????
}

template <class T>
void Coder<T>::encode(){
  T buf;
  uint32_t count = 0;
  if (data_length > 0) {
    buf = data[0];
    count++;
  }
  for(uint32_t i = 1; i < data_length; i++){
    if(buf != data[i]){
      encode_map.add(buf, count);
      buf = data[i];
      count = 1;
    }
    else{
      count++;
    }
  }
  //encode_map.sort();
  //encode_map.print();
}

template <class T>
void Coder<T>::decode(){
  for (auto block: encode_map.map) {
    for(uint32_t i = 0; i < block.get_freq(); i++){
      add(block.get_value());
    }
  }
}

template <class T>
void Coder<T>::write_code(const char * fname){
  analize();
  encode();
    
  File out;
  out.push(uint8_t(sizeof(T)));
    
  for (auto pat: freq_map.map) {
    out.push(pat.get_value());
  }
  out.push(T(0));
  out.push(T(0));
  
  uint32_t n;
  uint32_t l;
  for (auto block: encode_map.map) {
    l = block.get_freq();
    n = freq_map.get_num(block.get_value());
    //std::cout << "\n l: " << l;
    
    if((n == 0) && (l <= SIZE6)){
      out.push( uint8_t ((S0 << 6) | (l-1) ));
    }
    else if ((n == 1) && (l <= SIZE6)){
      out.push( uint8_t ((S1 << 6) | (l-1) ));
    }
    
    else if ((n == 2) && (l <= SIZE5)){
      out.push( uint8_t ((S2 << 5) | (l-1) ));
    }
    else if ((n == 3) && (l <= SIZE5)){
      out.push( uint8_t ((S3 << 5) | (l-1) ));
    }
    
    else if ((n == 4) && (l <= SIZE4)){
      out.push( uint8_t ((S4 << 4) | (l-1) ));
    }
    else if ((n == 5) && (l <= SIZE4)){
      out.push( uint8_t ((S5 << 4) | (l-1) ));
    }
    
    else if ((n < SIZE4) && (l <= SIZE8)){
      out.push( uint8_t ((SI << 4) | n ));
      out.push( uint8_t(l-1));
    }
    
    else if (n < SIZE8){
      if(l <= SIZE8){
          out.push(uint8_t(EX_1I1L));
          out.push(uint8_t(n));
          out.push(uint8_t(l-1));
      }
      else if(l <= SIZE16){
          out.push(uint8_t(EX_1I2L));
          out.push(uint8_t(n));
          out.push(uint16_t(l-1));
      }
      else if(l <= SIZE32){
          out.push(uint8_t(EX_1I4L));
          out.push(uint8_t(n));
          out.push(uint32_t(l-1));
      }
      else std::cout << "\n 8aaaa!";
    }
    
    else if (n < SIZE16){
      if(l <= SIZE8){
          out.push(uint8_t(EX_2I1L));
          out.push(uint16_t(n));
          out.push(uint8_t(l-1));
      }
      else if(l <= SIZE16){
          out.push(uint8_t(EX_2I2L));
          out.push(uint16_t(n));
          out.push(uint16_t(l-1));
      }
      else if(l <= SIZE32){
          out.push(uint8_t(EX_2I4L));
          out.push(uint16_t(n));
          out.push(uint32_t(l-1));
      }
      else std::cout << "\n 16aaaa!";
    }
    
    else if (n < SIZE32){
      if(l <= SIZE8){
          out.push(uint8_t(EX_4I1L));
          out.push(uint32_t(n));
          out.push(uint8_t(l-1));
      }
      else if(l <= SIZE16){
          out.push(uint8_t(EX_4I2L));
          out.push(uint32_t(n));
          out.push(uint16_t(l-1));
      }
      else if(l <= SIZE32){
          out.push(uint8_t(EX_4I4L));
          out.push(uint32_t(n));
          out.push(uint32_t(l-1));
      }
      else std::cout << "\n 32aaaa!";
    }
    else std::cout << "\n aaaa!";
  }
  out.write(fname);
  std::cerr << "\nHERE\n";
}

template <class T>
void Coder<T>::read_code(const char * fname){
  File in;
  in.read(fname);
  
  in.pick<uint8_t>();
  
  T buf = in.pick<T>();
  T buf_t = 0;
  
  while((buf_t == buf) == 0){
    freq_map.add(buf);
    buf_t = buf;
    buf = in.pick<T>();
    std::cout << "0x" << std::setfill('0') << std::setw(8) << std::hex
      << (uint64_t) buf << "\n";
  }
  for(buf = in.pick<uint8_t>(); !in.end(); buf = in.pick<uint8_t>()){
    if(cut(buf,0,6) == S0){
      encode_map.add(freq_map.get_val(0), cut(buf,2,0) + 1);
    }
    else if(cut(buf,0,6) == S1){
      encode_map.add(freq_map.get_val(1), cut(buf,2,0) + 1);
    }
    
    else if(cut(buf,1,5) == S2){
      encode_map.add(freq_map.get_val(2), cut(buf,3,0) + 1);
    }
    else if(cut(buf,1,5) == S3){
      encode_map.add(freq_map.get_val(3), cut(buf,3,0) + 1);
    }
    
    else if(cut(buf,2,4) == S4){
      encode_map.add(freq_map.get_val(4), cut(buf,4,0) + 1);
    }
    else if(cut(buf,2,4) == S5){
      encode_map.add(freq_map.get_val(5), cut(buf,4,0) + 1);
    }
    
    
    else if(cut(buf,3,4) == SI){
      uint8_t l = in.pick<uint8_t>();
      encode_map.add(freq_map.get_val(cut(buf,4,0)), l + 1);
    }
    
    else if(cut(buf,4,2) == EX_1I){
      uint8_t i = in.pick<uint8_t>();
      if(cut(buf,6,0) == EX_1L){
        uint8_t l = in.pick<uint8_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else if(cut(buf,6,0) == EX_2L){
        uint16_t l = in.pick<uint16_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else if(cut(buf,6,0) == EX_4L){
        uint32_t l = in.pick<uint32_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else std::cout << "\n 8aaaa!";
    }
    
    else if(cut(buf,4,2) == EX_2I){
      uint16_t i = in.pick<uint16_t>();
      if(cut(buf,6,0) == EX_1L){
        uint8_t l = in.pick<uint8_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else if(cut(buf,6,0) == EX_2L){
        uint16_t l = in.pick<uint16_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else if(cut(buf,6,0) == EX_4L){
        uint32_t l = in.pick<uint32_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else std::cout << "\n 16aaaa!";
    }
    
    else if(cut(buf,4,2) == EX_4I){
      uint32_t i = in.pick<uint32_t>();
      if(cut(buf,6,0) == EX_1L){
        uint8_t l = in.pick<uint8_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else if(cut(buf,6,0) == EX_2L){
        uint16_t l = in.pick<uint16_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else if(cut(buf,6,0) == EX_4L){
        uint32_t l = in.pick<uint32_t>();
        encode_map.add(freq_map.get_val(i), l + 1);
      }
      else std::cout << "\n 32aaaa!";
    }
    else std::cout << "\n aaaa!";
  }
  
}

//template class Pattern<char>;
//template class FreqMap<char>;
template class codec::Coder<uint8_t>;
template class codec::Coder<uint16_t>;
template class codec::Coder<uint32_t>;
template class codec:: Coder<uint64_t>;
