#!/usr/bin/env dyalogscript

sort←{
  input_file←⊃⍵
  output_dir←2⊃⍵
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
  ⍝ maximum number of blocks in the memory buffer
  n←⌊m÷b
  read_from_files←{
    0=⍴input_files:⍬
    current_file←(⊃input_files)⎕ntie 0
    input_files↓⍨←1
    read_from_current_file←{
      (loop_data i)start_byte←⍵
      i←{⍵≠0:⍵⋄a←⊃n(analyze loop_data)}i
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
  read_from_files ⍬ i
  ⎕nuntie⍬
}

analyze←{
  ⎕←⍴⍵
  0
}

main←{
  's'=2⊃⍵:sort 2↓⍵
  'a'=2⊃⍵:read_files 2↓⍵
}

main 2⎕nq#'getcommandlineargs'
