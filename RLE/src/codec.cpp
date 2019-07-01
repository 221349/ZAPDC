#include "codec.h"

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
  freq_map.print();
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
  encode_map.sort();
  encode_map.print();
}

//template class Pattern<char>;
//template class FreqMap<char>;
template class codec::Coder<uint8_t>;
template class codec::Coder<uint16_t>;
template class codec::Coder<uint32_t>;
template class codec:: Coder<uint64_t>;
