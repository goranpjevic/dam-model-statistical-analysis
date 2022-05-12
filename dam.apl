#!/usr/bin/env dyalogscript

sort←{
  input_file←⊃⍵
  output_dir←2⊃⍵
  mkdirsh←⎕sh'mkdir -p ',output_dir
  infd←input_file ⎕ntie 0
  blk←16×1024×1024
  loop←{
    data←⎕nread infd 80 blk ⍵
    0=≢data:⍵
    full_lines←⊃⌽⍸(⎕ucs 10)=data
    read_matrix←↑⍎¨(⎕ucs 10)(≠⊆⊢)full_lines↑data
    sorted_data←↑{⍵⌷read_matrix}¨⍋read_matrix
    outfd←(output_dir,'/')(⎕ncreate⍠'Unique'1)0
    w←(⊃,/{(⎕ucs 10),⍨⍕⍵}¨↓sorted_data)⎕nappend outfd
    ∇⍵+full_lines
  }
  end_byte←loop 0
  ⎕nuntie infd
  ⎕nuntie outfd
}

analyze←{
}

main←{
  's'=2⊃⍵:sort 2↓⍵
  'a'=2⊃⍵:analyze 2↓⍵
}

main 2⎕nq#'getcommandlineargs'
