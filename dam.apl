#!/usr/bin/env dyalogscript

sort←{
  input_file output_dir←⍵
  mkdirsh←⎕sh'mkdir -p ',output_dir
  infd←input_file⎕ntie 0
  blk←16×1024×1024
  loop←{
    data←⎕nread infd 80 blk ⍵
    0=≢data:⍵
    full_lines←⊃⌽⍸(⎕ucs 10)=data
    read_matrix←↑⍎¨(⎕ucs 10)(≠⊆⊢)full_lines↑data
    sorted_data←↑{⍵⌷read_matrix}¨⍋read_matrix
    outfd←(output_dir,'/')(⎕ncreate⍠'Unique'1)0
    w←(⊃,/{(⎕ucs 10),⍨⍕⍵}¨↓sorted_data)⎕nappend outfd
    nuntie_outfd←⎕nuntie outfd
    ∇⍵+full_lines
  }
  end_byte←loop 0
  ⎕nuntie infd
}

read_files←{
  input_dir m b minx maxx miny maxy bucket_size opt←⍵
  m b minx maxx miny maxy bucket_size←⍎¨m b minx maxx miny maxy bucket_size
  m b×←1024×1024
  input_files←⎕sh'ls ',input_dir,'/*'
  vals←⍬
  ⍝ maximum number of blocks in the memory buffer
  n←⌊m÷b
  read_from_files←{
    0=⍴input_files:⍬
    current_file←(⊃input_files)⎕ntie 0
    input_files↓⍨←1
    read_from_current_file←{
      (loop_data i)start_byte←⍵
      i←{⍵≠0:⍵⋄⊃n(vals,←filter loop_data minx maxx miny maxy opt)}i
      loop←{
        (loop_data i)start_byte←⍵
        ⍝ memory buffer is full
        i=0:(loop_data i)start_byte
        data←⎕nread current_file 80 b start_byte
        ⍝ finished reading the current file
        0=≢data:read_from_files loop_data i
        i-←1
        full_lines←⊃⌽⍸(⎕ucs 10)=data
        read_matrix←↑⍎¨(⎕ucs 10)(≠⊆⊢)full_lines↑data
        loop_data←{i=¯1+n:⍵⋄loop_data⍪⍵}read_matrix
        ∇(loop_data i)(start_byte+full_lines)
      }
      l←loop(loop_data i)start_byte
      2≠⍴l:⍬
      (loop_data i)start_byte←l
      i=0:∇(loop_data i)start_byte
      read_from_files loop_data i
    }
    read_from_current_file⍵0
  }
  i←n
  r←read_from_files ⍬ i
  nuntie_files←⎕nuntie⍬
  analyze vals bucket_size
}

filter←{
  data minx maxx miny maxy opt←⍵
  xyfilt←{((minx≤⍵)∧maxx≥⍵)∨(miny≤⍵)∧maxy≥⍵}data
  line_filter←∧⌿2↑⍉xyfilt
  good_lines←⍉line_filter/⍉data
  o←{
    ⍵='z':2
    ⍵='i':3
    ⍵='t':4
  }opt
  ,⍉1↑[2]o⌽good_lines
}

analyze←{
  vals B←⍵
  ⍝ number of buckets
  K←⌊1+B÷⍨(|⌊/-⌈/)vals
  ⍝ bucket indices for values
  bi←1+⌊B÷⍨(⊢-⌊/)vals
  ⍝ indices for buckets
  bid←∪((⊂⍋bi)⌷⊢)bi
  ⍝ buckets
  b←⊃⊆/((⊂⍋bi)⌷⊢)¨bi vals
  ⍝ first bucket value
  fbv←{(⌊/2⊃⍵)+2÷⍨⊃⍵}B vals
  ⍝ all bucket values
  bv←fbv+B×¯1+bid
  avg←((+/bv×⊢)÷+/)≢¨b
  std←.5*⍨((+/(2*⍨bv-avg)×⊢)÷+/)≢¨b
  ska←((+/(3*⍨bv-avg)×⊢)÷+/)≢¨b
  skb←(3÷2)*⍨((+/(2*⍨bv-avg)×⊢)÷((-K)++/))≢¨b
  sk←ska÷skb
  kua←((+/(4*⍨bv-avg)×⊢))≢¨b
  kub←2*⍨((+/(2*⍨bv-avg)×⊢))≢¨b
  ku←¯3+(+/≢¨b)×(kua÷kub)
  ⎕←'number of values: ',≢vals
  ⎕←'number of buckets: ',K
  ⎕←'average: ',avg
  ⎕←'standard deviation: ',std
  ⎕←'skewness: ',sk
  ⎕←'kurtosis: ',ku
}

main←{
  's'=2⊃⍵:sort 2↓⍵
  'a'=2⊃⍵:read_files 2↓⍵
}

main 2⎕nq#'getcommandlineargs'
