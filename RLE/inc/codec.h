#ifndef CODEC_H
#define CODEC_H

#include <cstdint>
#include <fstream>
#include <iterator>
#include <vector>
#include <algorithm>
#include <iostream>
#include <ios>
#include <bits/stdc++.h>

namespace codec
{
  template <class T>
  class Pattern{
    T value;
    uint32_t freq;
  public:
    Pattern(const Pattern <T> &pat);
    Pattern(T value);
    Pattern(T value, uint64_t freq);
    
    void operator ++(){ ++freq; }
    uint32_t get_freq(){ return freq; }
    T get_value(){ return value; }

    friend bool operator==(const Pattern<T> & i1, const Pattern<T> & i2){return i1.value == i2.value;}

    bool operator <(const Pattern<T> & r) const{ return (freq < r.freq); };
    //friend bool comparePattern(const Pattern<T> & i1, const Pattern<T> & i2);
  };

  //template <class T>
  //bool comparePattern(const Pattern<T> & i1, const Pattern<T> & i2){ return (i1.freq < i2.freq); }

  

  template <class T>
  class FreqMap{
    std::vector<Pattern<T>> map;
  public:
    void add(T & in);
    void print();
    void sort();
  };
  
  template <class T>
  class Encoder{
    std::vector<Pattern<T>> map;
  public:
    void add(T & in, uint64_t count);
    void print();
    void sort();
  };
  
  template <class T>
  class Coder{
    int pattern_size;

    T * data;
    uint64_t data_length;
    uint64_t data_space;

    FreqMap<T> freq_map;
    Encoder<T> encode_map;

    void check_space();
    void expand();
    void add(T value);

  public:
    Coder(const char * fname);
    
    void read(const char * fname);
    void write(const char * fname);
    void analize();
    void encode();
  };


}

#endif
