{
module StatefulParse where

import Base
import Lexer

import Data.Char

}

%name parser
%tokentype { Token }

%token 
    function { TokenKeyword "function" }
    if    { TokenKeyword "if" }
    else  { TokenKeyword "else" }
    true  { TokenKeyword "true" }
    false { TokenKeyword "false" }
    var   { TokenKeyword "var" }
    mutable { TokenKeyword "mutable" }
    return { TokenKeyword "return"}
    undefined { TokenKeyword "undefined"}
    ';'   { Symbol ";" }
    id    { TokenIdent $$ }
    digits { Digits $$ }
    '='    { Symbol "=" }
    '+'    { Symbol "+" }
    '-'    { Symbol "-" }
    '*'    { Symbol "*" }
    '/'    { Symbol "/" }
    '<'    { Symbol "<" }
    '>'    { Symbol ">" }
    '<='   { Symbol "<=" }
    '>='   { Symbol ">=" }
    '=='   { Symbol "==" }
    '&&'   { Symbol "&&" }
    '!'    { Symbol "!" }
    '@'    { Symbol "@" }
    '||'   { Symbol "||" }
    '('    { Symbol "(" }
    ')'    { Symbol ")" }
    '{'    { Symbol "{" }
    '}'    { Symbol "}" }

%%

Exp : function '(' id ')' '{' Exp '}'  { Function $3 $6 }
    | var id '=' Exp ';' Exp           { Declare $2 $4 $6 }
    | if '(' Exp ')' '{' Exp '}' else '{' Exp '}'  { If $3 $6 $10 }
    | Exp ';' Exp                      { Seq $1 $3 }
    | return Exp                       { Return $2 }
    | Assign                           { $1 }

Assign : Or '=' Assign    { Assign $1 $3 }
       | Or               { $1 }

Or   : Or '||' And        { Binary Or $1 $3 }
     | And                { $1 }

And  : And '&&' Comp      { Binary And $1 $3 }
     | Comp               { $1 }

Comp : Comp '==' Term     { Binary Equal        $1 $3 }
     | Comp '<' Term      { Binary Less         $1 $3 }
     | Comp '>' Term      { Binary Greater      $1 $3 }
     | Comp '<=' Term     { Binary LessEqual    $1 $3 }
     | Comp '>=' Term     { Binary GreaterEqual $1 $3 }
     | Term               { $1 }

Term : Term '+' Factor    { Binary Add $1 $3 }
     | Term '-' Factor    { Binary Sub $1 $3 }
     | Factor             { $1 }

Factor : Factor '*' Primary    { Binary Mul $1 $3 }
       | Factor '/' Primary    { Binary Div $1 $3 }
       | Primary               { $1 }

Primary : Primary '(' Exp ')' { Call $1 $3 }
        | digits         { Literal (IntV $1) }
        | true           { Literal (BoolV True) }
        | false          { Literal (BoolV False) }
        | undefined      { Literal (UndefinedV) }
        | '-' Primary    { Unary Neg $2 }
        | '!' Primary    { Unary Not $2 }
        | '@' Primary    { Access $2 }
        | mutable Primary { Mutable $2 }
        | id             { Variable $1 }
        | '(' Exp ')'    { $2 }

{

symbols = ["+", "-", "*", "/", "(", ")", "{", "}", ";", "==", "=", "<=", ">=", "<", ">", "||", "&&", "!", "@"]
keywords = ["function", "var", "if", "else", "true", "false", "mutable", "return", "undefined"]
parseExp str = parser (lexer symbols keywords str)

parseInput = do
  input <- getContents
  print (parseExp input)

}
