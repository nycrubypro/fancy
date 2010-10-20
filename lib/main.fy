require: "boot"
rb_require: "rbx/eval"

ARGV for_options: ["-v", "--version"] do: {
  "fancy " ++ FANCY_VERSION println
  "(C) 2010 Christopher Bertels <chris@fancy-lang.org>" println
}

ARGV for_options: ["--help", "-h"] do: {
  ["Usage: fancy [option] [programfile] [arguments]",
   "  --help        Print this output",
   "  -h            Print this output",
   "  --version     Print Fancy's version number",
   "  -v            Print Fancy's version number",
   "  -I directory  Add directory to Fancy's LOAD_PATH",
   "  -e 'command'  One line of Fancy code that gets evaluated immediately",
   "  --sexp        Print out the Fancy code within a source file as S-Expressions instead of evaluating it ",
   "  -c            Compile given files to Rubinius bytecode",
   "  -cv           Compile given files to Rubinius bytecode verbosely (outputting the generated bytecode).",
   "  -rbx          Compile given files to Rubinius bytecode and run it immediately",
   "  --rsexp       Print out the Fancy code within a source file as Ruby S-Expressions instead of evaluating it ",
   "  --rsexp-nice  Same like --rsexp, but with pretty formatting and colors.",
   "  -o            Output compiled Ruby code to a given file name"] println
}

ARGV for_option: "-e" do: |eval_string| {
  eval_string eval
  System exit # quit when running with -e
}

# ARGV for_option: "-o" do: |out_file| {
#   COMPILE_OUT_STREAM = File open: out_file modes: ['write]
#   out_file_idx = ARGV index: "-o"
#   # remove -o with given arg
#   2 times: { ARGV remove_at: out_file_idx }
# }

# ARGV for_option: "-c" do: {
#   ARGV index: "-c" . if_do: |idx| {
#     ARGV[[idx + 1, -1]] each: |filename| {
#       System do: ("rbx rbx/compiler.rb " ++ filename)
#     }
#   }
#   System exit
# }

# ARGV for_option: "-cv" do: {
#   ARGV index: "-cv" . if_do: |idx| {
#     ARGV[[idx + 1, -1]] each: |filename| {
#       System do: ("rbx rbx/compiler.rb " ++ filename ++ " -B")
#     }
#   }
#   System exit
# }

# ARGV for_option: "-rbx" do: {
#   ARGV index: "-rbx" . if_do: |idx| {
#     ARGV[[idx + 1, -1]] each: |filename| {
#       System do: ("rbx rbx/loader.rb " ++ filename)
#     }
#   }
#  System exit
# }

# ARGV for_option: "--rsexp" do: {
#   require: "lib/compiler/nodes.fy"
#   ARGV index: "--rsexp" . if_do: |idx| {
#     ARGV[[idx + 1, -1]] each: |filename| {
#       exp = System pipe: ("bin/fancy " ++ filename ++ " --sexp")
#       exp first eval to_ast to_ruby_sexp: COMPILE_OUT_STREAM
#       COMPILE_OUT_STREAM newline
#     }
#   }
#   System exit
# }

# ARGV for_option: "--rsexp-nice" do: {
#   ARGV index: "--rsexp-nice" . if_do: |idx| {
#     ARGV[[idx + 1, -1]] each: |filename| {
#       exp = System pipe: ("bin/fancy --rsexp " ++ filename)
#       System do: ("rbx rbx/rsexp_pretty_printer.rb " ++ "'" ++ exp ++ "'")
#     }
#   }
#   System exit
# }

ARGV first if_do: |file| {
  Fancy::CodeLoader load_compiled_file(file)
}

