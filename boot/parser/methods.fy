class Fancy {
  class Parser {

    def self parse_file: filename line: line (1) {
      new: filename line: line . parse_file . script
    }

    read_write_slots: ['filename, 'line, 'script]

    def initialize: @filename line: @line { }

    def body: body {
      @script = AST Script new: @line file: @filename body: body
    }

    def ast: line exp_list: expr into: list (AST ExpressionList new: line) {
      expr if_do: { list expressions << expr }
      list
    }

    def ast: line identity: identity { identity }

    def ast: line concat: object into: ary ([]) {
      object kind_of?(Array) . if_do: {
        ary concat(object)
      } else: {
        ary << object
      }
    }

    def ast: line key: key value: value into: ary {
      ary nil? if_true: { ary = [] }
      ary << key
      ary << value
      ary
    }

    def ast: line fixnum: text base: base (10) {
      AST FixnumLiteral new: line value: (text to_i(base))
    }

    def ast: line number: text base: base (10) {
      AST NumberLiteral new: line value: (text to_f())
    }

    def ast: line symbol: text {
      str = text from: 1 to: -1
      AST SymbolLiteral new: line value: str
    }

    def ast: line string: text {
      str = text from: 1 to: -2
      AST StringLiteral new: line value: str
    }

    def ast: line array: expr_ary {
      AST ArrayLiteral new: line array: expr_ary
    }

    def ast: line hash: key_values {
      AST HashLiteral new: line entries: key_values
    }

    def ast: line tuple: expr_ary {
      expr_ary size == 1 . if_do: { expr_ary first } else: {
        AST TupleLiteral new: line entries: expr_ary
      }
    }

    def ast: line identifier: text {
      AST Identifier from: text line: line
    }

    def ast: line constant: identifier parent: parent {
      AST NestedConstant new: line const: identifier parent: parent
    }

    def ast: line super_exp: text { AST Super new: line }

    def ast: line retry_exp: text { AST Retry new: line }

    def ast: line assign: rvalue to: lvalue many: many (false) {
      ast = many if_do: { AST MultipleAssignment } else: { AST Assignment }
      ast new: line var: lvalue value: rvalue
    }

    def ast: line param: selector var: variable default: default (nil) {
      Struct.new('selector, 'variable, 'default) new(selector, variable, default)
    }

    def ast: line send: selector arg: value ary: ary ([]) {
      ary << $ Struct new('selector, 'value) new(selector, value)
    }

    def ast: line oper: oper arg: arg to: receiver (AST Self new line) ruby: ruby (false) {
      message = ast: line send: oper arg: arg
      ast: line send: message to: receiver ruby: ruby
    }

    def ast: line send: message to: receiver (AST Self new: line) ruby: ruby (false) {
      arg_type = ruby if_do: { AST RubyArgs } else: { AST MessageArgs }
      args = arg_type new: line args: []
      name = message
      message kind_of?(String) . if_do: {
        name = AST Identifier from: message line: line
      }
      message kind_of?(Array) . if_do: {
        name = message map: |m| { m selector() string } . join
        name = AST Identifier new: line string: name
        args = message map: |m| { m value() }
        args = arg_type new: line args: args
      }
      AST MessageSend new: line message: name to: receiver args: args
    }

    def method_name: margs {
      margs map: |a| { a selector() string } . join("")
    }

    def method: margs delegators: block {
      idx = margs index() |m| { m default() != nil }
      idx if_do: {
        line = margs first selector() line
        target = method_name: margs
        (margs size - idx) times: |pos| {
          required = margs from: 0 to: (idx + pos)
          default = margs from: (idx+pos) to: -1
          params = required map: 'variable . + $ default map: 'default

          forward = AST MessageSendo new: line \
                                    message: (AST Identifier from: target line: line) \
                                    to:  (AST Self new: line)                     \
                                    args:(AST MessageArgs new: line args: params)

          doc = AST StringLiteral new: line value: ("Forward to message " ++ target)
          body = AST ExpressionList new: [doc, forward] line: line
          block call: [required, body]
        }
      }
    }

    def ast: line oper: op arg: arg body: body access: access ('public) owner: owner (nil) {
      margs = ast: line param: op var: arg
      ast: line method: margs body: body access: access owner: owner
    }

    def ast: line method: margs body: body access: access ('public) owner: owner (nil) {
      margs is_a?(AST Identifier) . if_do: {
        args = AST MethodArgs new: line args: []
        owner if_do: {
          AST SingletonMethodDef new: line name: margs args: args \
                                 body: body access: access owner: owner
        } else: {
          AST MethodDef new: line name: margs args: args body: body access: access
        }
      } else: {
        name = method_name: margs
        name = AST Identifier new: line string: name
        args = margs map() |m| { m variable() string }
        args = AST MethodArgs new: line args: args
        owner if_do: {
          AST SingletonMethodDef new: line name: name args: args \
                                 body: body access: access owner: owner
        } else: {
          AST MethodDef new: line name: name args: args body: body access: access
        }
      }
    }

    def ast: line method: margs expand: body access: access ('public) owner: owner (nil) {
      defs = []
      method: margs delegators: |sel fwd| {
        defs << $ ast: line method: sel body: fwd access: access owner: owner
      }
      defs << $ ast: line method: margs body: body access: access owner: owner
      AST ExpressionList new: line list: defs
    }

    def ast: line block: body {
      args = AST BlockArgs new: line
      AST BlockLiteral new: line args: args body: body
    }

    def ast: line block: body args: args {
      args = AST BlockArgs new: line args: args
      AST BlockLiteral new: line args: args body: body
    }

    def ast: line require_: file {
      AST Require new: line file: file
    }

    def ast: line class: name parent: parent body: body {
      AST ClassDef new: line name: name parent: parent body: body
    }
  }
}