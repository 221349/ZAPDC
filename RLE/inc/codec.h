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

#define H1 1
#define H2 2
#define H4 4
#define H8 8

#define SIZE32 4294967296
#define SIZE16 65536
#define SIZE8 256
#define SIZE6 64
#define SIZE5 32
#define SIZE4 16

#define S0 0b10
#define S1 0b11

#define S2 0b010
#define S3 0b011

#define S4 0b0010
#define S5 0b0011

#define SI 0b0001

#define EX_IL 0b0000

#define EX_1I1L 0b00000000
#define EX_1I2L 0b00000001
#define EX_1I4L 0b00000010

#define EX_2I1L 0b00000100
#define EX_2I2L 0b00000101
#define EX_2I4L 0b00000110

#define EX_4I1L 0b00001000
#define EX_4I2L 0b00001001
#define EX_4I4L 0b00001010


#define EX_1I 0b000000
#define EX_1L 0b00000000

#define EX_2I 0b000001
#define EX_2L 0b00000001

#define EX_4I 0b000010
#define EX_4L 0b00000010




#define cut(val, begin, end) ( (val & (0b11111111 >> begin) ) >> (end))

  int read_header(const char * fname);

namespace codec
{
    
    
  template <class T>
  class Pattern{
    T value;
    uint32_t freq;
  public:
    Pattern(const Pattern <T> &pat);
    Pattern(T value);
    Pattern(T value, uint32_t freq);
    
    void operator ++(){ ++freq; }
    uint32_t get_freq(){ return freq; }
    T get_value(){ return value; }

    friend bool operator==(const Pattern<T> & i1, const Pattern<T> & i2){return i1.value == i2.value;}

    bool operator <(const Pattern<T> & r) const{ return (freq > r.freq); };
  };


  template <class T>
  class FreqMap{
  public:
    std::vector<Pattern<T>> map;
    
    void add(T & in);
    void print();
    void sort();
    
    uint32_t get_num(const T & value);
    T get_val(const uint32_t num);
  };
  
  template <class T>
  class Encoder{
  public:
    std::vector<Pattern<T>> map;
    
    void add(const T & in, uint64_t count);
    void print();
    void sort();
  };
  
  template <class T>
  class Coder{
    //int pattern_size;

    T * data;
    uint64_t data_length;
    uint64_t data_space;

    FreqMap<T> freq_map;
    Encoder<T> encode_map;

    void check_space();
    void expand();
    void add(T value);

  public:
    Coder();
    Coder(const char * fname);
    
    void read(const char * fname);
    void write(const char * fname);
    void analize();
    void encode();
    void decode();
    void write_code(const char * fname);
    void read_code(const char * fname);
  };

  class File{
    //char buf;
    uint64_t data_pos;
    
    char * data;
    uint64_t data_length;
    uint64_t data_space;
    

    void check_space();
    void expand();
    void add(const char & value);
    
    
  public:
    File();
    
    void read(const char * fname);
    void write(const char * fname);
    
    bool end(){ return data_pos >= data_length; }
    
    template <class T>
    void push(const T value);
    
    template <class T>
    T pick();
  };
}

#endif
