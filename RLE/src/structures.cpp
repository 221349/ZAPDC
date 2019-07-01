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
void Encoder<T>::add(T & in, uint64_t count){
  map.push_back(Pattern<T>(in, count));
}

template <class T>
void Encoder<T>::sort(){
  std::sort(map.begin(), map.end());
}

template class Pattern<uint8_t>;
template class Pattern<uint16_t>;
template class Pattern<uint32_t>;
template class Pattern<uint64_t>;

template class FreqMap<uint8_t>;
template class FreqMap<uint16_t>;
template class FreqMap<uint32_t>;
template class FreqMap<uint64_t>;

template class Encoder<uint8_t>;
template class Encoder<uint16_t>;
template class Encoder<uint32_t>;
template class Encoder<uint64_t>;
