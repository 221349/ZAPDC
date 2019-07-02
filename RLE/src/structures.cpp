#include "codec.h"

using namespace codec;

/************************************
**  PATTERN:
************************************/

template <class T>
Pattern<T>::Pattern(const Pattern <T> &pat){
  this->value = pat.value;
  this->freq = pat.freq;
}

template <class T>
Pattern<T>::Pattern(T value){
  this->value = value;
  freq = 0;
}

template <class T>
Pattern<T>::Pattern(T value, uint64_t freq){
  this->value = value;
  this->freq = freq;
}


/************************************
**  FREQMAP:
************************************/

template <class T>
void FreqMap<T>::print(){
  const int length = sizeof(T) * 2;
  for(typename std::vector<codec::Pattern<T>>::iterator it = map.begin(); it != map.end(); ++it){
    std::cout << (int)(it - map.begin()) << ": '"
      << "0x" << std::setfill('0') << std::setw(length) << std::hex
      << (uint64_t) it->get_value() << std::dec << "' f="<< it->get_freq() << "\n";
  }
}

template <class T>
void FreqMap<T>::add(T & in){
  auto cell = std::find(map.begin(), map.end(), Pattern<T>(in));
  if(cell == map.end()){
    map.push_back(Pattern<T>(in));
    ++map.back();
  }
  else{
    ++(*cell);
  }
}

template <class T>
void FreqMap<T>::sort(){
  std::sort(map.begin(), map.end());
}

template <class T>
uint32_t FreqMap<T>::get_num(const T & value){
  auto cell = std::find(map.begin(), map.end(), Pattern<T>(value));
  return (uint32_t)(cell - map.begin());
}

template <class T>
T FreqMap<T>::get_val(const uint32_t num){
  return map[num].get_value();
}



/************************************
**  ENCODER:
************************************/

template <class T>
void Encoder<T>::print(){
  const int length = sizeof(T) * 2;
  for(typename std::vector<codec::Pattern<T>>::iterator it = map.begin(); it != map.end(); ++it){
    std::cout << (int)(it - map.begin()) << ": '"
      << "0x" << std::setfill('0') << std::setw(length) << std::hex
      << (uint64_t) it->get_value() << std::dec << "' f="<< it->get_freq() << "\n";
  }
}

template <class T>
void Encoder<T>::add(const T & in, uint64_t count){
  map.push_back(Pattern<T>(in, count));
}

template <class T>
void Encoder<T>::sort(){
  std::sort(map.begin(), map.end());
}


/************************************
**  FILE:
************************************/

File::File(){
  data_length = 0;
  data = new char[1];
  data_space = 1;
  
  data_pos = 0;
}


void File::check_space(){
  if(data_length < data_space) return;
  expand();
}

void File::expand(){
  data_space *= 2;
  char * tmp = data;
  data = new char[data_space];
  for(uint64_t i = 0; i < data_length; i++){
    data[i] = tmp[i];
  }
  delete[] tmp;
}

void File::add(const char & value){
  check_space();
  data[data_length] = value;
  data_length++;
}

void File::write(const char * fname){
  std::ofstream f (fname,std::ofstream::binary);
  f.write(data, data_length);  
  f.close();
  data_pos = 0;
}

void File::read(const char * fname){
  std::ifstream f(fname, std::ios::binary | std::ios::in);
  char c;
  while (f.get(c))
  {
    add(c);
  }
  f.close();
}

template <class T>
void File::push(const T value){
  char s;
  const int block_size = sizeof(value)/sizeof(s);
  const int r_block_size = sizeof(s) * 8;
  
  for(int p = block_size - 1; p >= 0; p--){
    s = value >> (r_block_size * p);
    add(s);
  }
}

template <class T>
T File::pick(){
  T buf = 0;
  char s;
  
  const int block_size = sizeof(buf)/sizeof(s);
  const int r_block_size = sizeof(s) * 8;
  
  for(int p = block_size - 1; p >= 0; p--){
    s = data[data_pos];
    buf = buf | ( uint8_t(s) << (r_block_size * p));
    data_pos++;
  }
  return buf;
}
/*
void File::push(const uint8_t value, const uint8_t begin, const uint8_t length){
  const int r_block_size = sizeof(c) * 8;
  
  buf = buf | ( (value & (0b11111111 >> begin) >> (r_block_size - )
  if ( (begin - end) > 
    
    char s;
  
  for(int p = block_size - 1; p >= 0; p--){
    s = value >> (r_block_size * p);
    add(s);
  }
}*/

template class codec::Pattern<uint8_t>;
template class codec::Pattern<uint16_t>;
template class codec::Pattern<uint32_t>;
template class codec::Pattern<uint64_t>;

template class codec::FreqMap<uint8_t>;
template class codec::FreqMap<uint16_t>;
template class codec::FreqMap<uint32_t>;
template class codec::FreqMap<uint64_t>;

template class codec::Encoder<uint8_t>;
template class codec::Encoder<uint16_t>;
template class codec::Encoder<uint32_t>;
template class codec::Encoder<uint64_t>;


//template class codec::File::push(<bool>);
template void codec::File::push<uint8_t>(const uint8_t value);
template void codec::File::push<uint16_t>(const uint16_t value);
template void codec::File::push<uint32_t>(const uint32_t value);
template void codec::File::push<uint64_t>(const uint64_t value);

template uint8_t codec::File::pick<uint8_t>();
template uint16_t codec::File::pick<uint16_t>();
template uint32_t codec::File::pick<uint32_t>();
template uint64_t codec::File::pick<uint64_t>();
